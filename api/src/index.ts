import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { CosmosClient, SqlQuerySpec } from "@azure/cosmos";
import { DefaultAzureCredential } from "@azure/identity";
import crypto from "node:crypto";
import { validateBearerToken } from "./auth";

type GameMode = "daily" | "season";

type SubmitScoreBody = {
  leaderboardId: string;
  mode: GameMode;
  scoreValue: number;
};

type ScoreDocument = {
  id: string;
  leaderboardId: string;
  playerId: string;
  displayName: string;
  mode: GameMode;
  scoreValue: number;
  achievedUtc: string;
};

type LeaderboardEntry = {
  id: string;
  playerId: string;
  displayName: string;
  scoreValue: number;
  achievedUtc: string;
};

type RemoteConfigDocument = {
  id: string;
  adFrequency?: number;
  featureFlags?: Record<string, boolean>;
  [key: string]: unknown;
};

const requiredEnv = [
  "COSMOS_ENDPOINT",
  "COSMOS_DATABASE",
  "COSMOS_CONTAINER_SCORES",
  "COSMOS_CONTAINER_CONFIG"
] as const;

function getEnv(name: (typeof requiredEnv)[number]): string {
  const value = process.env[name];
  if (!value || value.trim().length === 0) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function isGameMode(value: unknown): value is GameMode {
  return value === "daily" || value === "season";
}

function json(status: number, body: unknown): HttpResponseInit {
  return {
    status,
    jsonBody: body,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-store"
    }
  };
}

function parseMode(value: string | null): GameMode {
  return value === "daily" ? "daily" : "season";
}

function parseLimit(value: string | null, fallback = 20, max = 100): number {
  if (!value) return fallback;
  const parsed = Number.parseInt(value, 10);
  if (Number.isNaN(parsed) || parsed < 1) return fallback;
  return Math.min(parsed, max);
}

function bodySizeBytes(body: unknown): number {
  try {
    return Buffer.byteLength(JSON.stringify(body), "utf8");
  } catch {
    return Number.MAX_SAFE_INTEGER;
  }
}

const cosmosClient = new CosmosClient({
  endpoint: getEnv("COSMOS_ENDPOINT"),
  aadCredentials: new DefaultAzureCredential()
});

const db = cosmosClient.database(getEnv("COSMOS_DATABASE"));
const scores = db.container(getEnv("COSMOS_CONTAINER_SCORES"));
const config = db.container(getEnv("COSMOS_CONTAINER_CONFIG"));

app.http("submitScore", {
  methods: ["POST"],
  authLevel: "anonymous",
  route: "score",
  handler: async (req: HttpRequest, ctx: InvocationContext): Promise<HttpResponseInit> => {
    try {
      const auth = await validateBearerToken(req.headers.get("authorization"));
      const body = (await req.json()) as Partial<SubmitScoreBody>;

      if (
        typeof body.leaderboardId !== "string" ||
        body.leaderboardId.trim().length === 0 ||
        typeof body.scoreValue !== "number" ||
        !Number.isFinite(body.scoreValue) ||
        body.scoreValue < 0 ||
        body.scoreValue > 1_000_000 ||
        !isGameMode(body.mode)
      ) {
        return json(400, { error: "Invalid payload." });
      }

      const doc: ScoreDocument = {
        id: crypto.randomUUID(),
        leaderboardId: body.leaderboardId.trim(),
        playerId: auth.subject,
        displayName: auth.displayName,
        mode: body.mode,
        scoreValue: Math.floor(body.scoreValue),
        achievedUtc: new Date().toISOString()
      };

      await scores.items.create(doc);
      return json(202, { accepted: true, id: doc.id });
    } catch (error) {
      ctx.error("submitScore failed");
      return json(401, { error: "Unauthorized or invalid request." });
    }
  }
});

app.http("getLeaderboard", {
  methods: ["GET"],
  authLevel: "anonymous",
  route: "leaderboard",
  handler: async (req: HttpRequest, ctx: InvocationContext): Promise<HttpResponseInit> => {
    try {
      await validateBearerToken(req.headers.get("authorization"));
      const leaderboardId = (req.query.get("leaderboardId") ?? "global").trim();
      const mode = parseMode(req.query.get("mode"));
      const limit = parseLimit(req.query.get("limit"));

      const query: SqlQuerySpec = {
        query: `
          SELECT TOP @limit
            c.id,
            c.playerId,
            c.displayName,
            c.scoreValue,
            c.achievedUtc
          FROM c
          WHERE c.leaderboardId = @leaderboardId
            AND c.mode = @mode
          ORDER BY c.scoreValue DESC, c.achievedUtc ASC
        `,
        parameters: [
          { name: "@limit", value: limit },
          { name: "@leaderboardId", value: leaderboardId },
          { name: "@mode", value: mode }
        ]
      };

      const { resources } = await scores.items.query<LeaderboardEntry>(query).fetchAll();
      return json(200, { leaderboardId, mode, entries: resources });
    } catch {
      ctx.error("getLeaderboard failed");
      return json(401, { error: "Unauthorized." });
    }
  }
});

app.http("getConfig", {
  methods: ["GET"],
  authLevel: "anonymous",
  route: "config",
  handler: async (req: HttpRequest, ctx: InvocationContext): Promise<HttpResponseInit> => {
    try {
      await validateBearerToken(req.headers.get("authorization"));
      const { resource } = await config.item("liveConfig", "liveConfig").read<RemoteConfigDocument>();
      return json(
        200,
        resource ?? {
          id: "liveConfig",
          adFrequency: 3,
          featureFlags: {}
        }
      );
    } catch {
      ctx.error("getConfig failed");
      return json(401, { error: "Unauthorized." });
    }
  }
});

app.http("postTelemetry", {
  methods: ["POST"],
  authLevel: "anonymous",
  route: "telemetry",
  handler: async (req: HttpRequest, ctx: InvocationContext): Promise<HttpResponseInit> => {
    try {
      const auth = await validateBearerToken(req.headers.get("authorization"));
      const body = await req.json();

      if (bodySizeBytes(body) > 16_384) {
        return json(413, { error: "Payload too large." });
      }

      const eventType =
        typeof (body as { eventType?: unknown }).eventType === "string"
          ? ((body as { eventType: string }).eventType.slice(0, 64))
          : "unknown";

      ctx.log("Telemetry accepted", { playerId: auth.subject, eventType });
      return json(202, { accepted: true });
    } catch {
      ctx.error("postTelemetry failed");
      return json(401, { error: "Unauthorized or invalid payload." });
    }
  }
});