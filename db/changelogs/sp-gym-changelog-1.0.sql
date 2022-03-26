--liquibase formatted sql

--changeset sp-gym-changelog-1.0:1 author:someone failOnError:true
CREATE SCHEMA IF NOT EXISTS "gym";
--rollback DROP SCHEMA "gym";

--changeset sp-gym-changelog-1.0:2 author:sshetty failOnError:true
CREATE TABLE IF NOT EXISTS "gym"."trainers" (
"id" UUID DEFAULT gen_random_uuid() NOT NULL, 
"created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL, 
"updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL, 
"deleted_at" TIMESTAMP WITH TIME ZONE, 
"name" VARCHAR(255) NOT NULL, 
"age" INTEGER NOT NULL,
"city" VARCHAR(255), 
CONSTRAINT "trainers_key" PRIMARY KEY ("id"));
--rollback DROP TABLE gym.trainers;