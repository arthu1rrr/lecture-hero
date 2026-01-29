CREATE TABLE "lecture_sets" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"slug" text NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"university" text,
	"course" text,
	"module" text,
	"visibility" text DEFAULT 'private' NOT NULL,
	"created_by_user_id" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "lecture_sets_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "lectures" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"lecture_set_id" uuid NOT NULL,
	"title" text NOT NULL,
	"index_in_set" integer NOT NULL,
	"lecturer" text,
	"source_url" text,
	"start_at" timestamp with time zone NOT NULL,
	"duration_minutes" integer,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "set_uploads" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"uploaded_by_user_id" text,
	"lecture_set_id" uuid NOT NULL,
	"status" text DEFAULT 'processing' NOT NULL,
	"raw_json" jsonb NOT NULL,
	"normalized_json" jsonb,
	"error_message" text,
	"created_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_lectures" (
	"user_id" text NOT NULL,
	"lecture_id" uuid NOT NULL,
	"completed" boolean DEFAULT false NOT NULL,
	"completed_at" timestamp with time zone,
	CONSTRAINT "user_lectures_user_id_lecture_id_pk" PRIMARY KEY("user_id","lecture_id")
);
--> statement-breakpoint
CREATE TABLE "user_sets" (
	"user_id" text NOT NULL,
	"lecture_set_id" uuid NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "user_sets_user_id_lecture_set_id_pk" PRIMARY KEY("user_id","lecture_set_id")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"name" text,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "lecture_sets" ADD CONSTRAINT "lecture_sets_created_by_user_id_users_id_fk" FOREIGN KEY ("created_by_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "lectures" ADD CONSTRAINT "lectures_lecture_set_id_lecture_sets_id_fk" FOREIGN KEY ("lecture_set_id") REFERENCES "public"."lecture_sets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "set_uploads" ADD CONSTRAINT "set_uploads_uploaded_by_user_id_users_id_fk" FOREIGN KEY ("uploaded_by_user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "set_uploads" ADD CONSTRAINT "set_uploads_lecture_set_id_lecture_sets_id_fk" FOREIGN KEY ("lecture_set_id") REFERENCES "public"."lecture_sets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_lectures" ADD CONSTRAINT "user_lectures_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_lectures" ADD CONSTRAINT "user_lectures_lecture_id_lectures_id_fk" FOREIGN KEY ("lecture_id") REFERENCES "public"."lectures"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_sets" ADD CONSTRAINT "user_sets_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_sets" ADD CONSTRAINT "user_sets_lecture_set_id_lecture_sets_id_fk" FOREIGN KEY ("lecture_set_id") REFERENCES "public"."lecture_sets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "unique_lecture_index" ON "lectures" USING btree ("lecture_set_id","index_in_set");--> statement-breakpoint
CREATE INDEX "user_lectures_user_id_index" ON "user_lectures" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "user_lectures_lecture_id_index" ON "user_lectures" USING btree ("lecture_id");--> statement-breakpoint
CREATE INDEX "user_sets_user_id_index" ON "user_sets" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "user_sets_set_id_index" ON "user_sets" USING btree ("lecture_set_id");