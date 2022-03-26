--liquibase formatted sql

--changeset sp-gym-changelog-1.1:1 author:sshetty failOnError:true

CREATE TABLE IF NOT EXISTS "gym"."students" (
    "id" UUID DEFAULT gen_random_uuid() NOT NULL,
    "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
    "deleted_at" TIMESTAMP WITH TIME ZONE, "name" VARCHAR(255) NOT NULL,
    age INTEGER NOT NULL,
    city VARCHAR(255),
    CONSTRAINT "students_key" PRIMARY KEY ("id"));
--rollback DROP TABLE gym.students;