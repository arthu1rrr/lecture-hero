import {
  pgTable,
  text,
  timestamp,
  uuid,
  integer,
  boolean,
  jsonb,
  primaryKey,
  uniqueIndex,
  index,
} from "drizzle-orm/pg-core";

export const users = pgTable("users", {
    id: text("id").primaryKey(),
    email: text("email").notNull().unique(),
    name: text("name"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
});

export const lectureSets = pgTable("lecture_sets", {
    id: uuid("id").defaultRandom().primaryKey(),
    slug: text("slug").notNull().unique(),
    title: text("title").notNull(),
    description: text("description"),
    university: text("university"),
    course: text("course"),
    module: text("module"),
    visibility: text("visibility").notNull().default("private"),
    createdByUserId: text("created_by_user_id")
        .references(() => users.id, { onDelete: "set null" }),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
}); 

export const lectures = pgTable("lectures", {
    id: uuid("id").defaultRandom().primaryKey(),
    lectureSetId: uuid("lecture_set_id")
        .references(() => lectureSets.id, { onDelete: "cascade" })
        .notNull(),

    title: text("title").notNull(),
    indexInSet: integer("index_in_set").notNull(),
    lecturer: text("lecturer"),
    sourceUrl: text("source_url"),
    startAt: timestamp("start_at", {withTimezone: true}).notNull(),
    durationMinutes: integer("duration_minutes"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
},
(table) => [
uniqueIndex("unique_lecture_index").on(
        table.lectureSetId,
        table.indexInSet
    ),
]);

export const userSets = pgTable("user_sets", {
    userId: text("user_id")
        .references(() => users.id, { onDelete: "cascade" })
        .notNull(),
    lectureSetId: uuid("lecture_set_id")
        .references(() => lectureSets.id, { onDelete: "cascade" })
        .notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
}, (table) => [
    primaryKey({columns: [table.userId, table.lectureSetId]}),
    index("user_sets_user_id_index").on(table.userId),
    index("user_sets_set_id_index").on(table.lectureSetId),
]);

export const userLectures = pgTable("user_lectures", {
    userId: text("user_id")
        .references(() => users.id, { onDelete: "cascade" })
        .notNull(),
    lectureId: uuid("lecture_id")
        .references(() => lectures.id, { onDelete: "cascade" })
        .notNull(),
    completed: boolean("completed").default(false).notNull(),
    completedAt: timestamp("completed_at", {withTimezone: true}),
}, (table) => [
    primaryKey({columns: [table.userId, table.lectureId]}),
    index("user_lectures_user_id_index").on(table.userId),
    index("user_lectures_lecture_id_index").on(table.lectureId),
]);

export const setUploads = pgTable("set_uploads", {
    id: uuid("id").defaultRandom().primaryKey(),
    uploadedByUserId: text("uploaded_by_user_id")
        .references(() => users.id, { onDelete: "set null" }),
    lectureSetId: uuid("lecture_set_id")
        .references(() => lectureSets.id, { onDelete: "cascade" })
        .notNull(),
    status: text("status").notNull().default("processing"),
    rawJson: jsonb("raw_json").notNull(),
    normalizedJson: jsonb("normalized_json"),
    errorMessage: text("error_message"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
});