import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

const globalForDb = globalThis as unknown as { conn?: postgres.Sql };

export const conn =
  globalForDb.conn ??
  postgres(process.env.DATABASE_URL!, {
    ssl: "require",
    max: 1, // dev-friendly; we’ll tune later
  });

if (process.env.NODE_ENV !== "production") globalForDb.conn = conn;

export const db = drizzle(conn);