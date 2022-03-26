--liquibase formatted sql

--changeset sp-gym-changelog-1.2:1 author:sshetty failOnError:true
INSERT INTO "gym"."trainers"(name,age,city) VALUES 
('foo',3,'somecity'),
('bar',4,'somebar');
--rollback DELETE from "gym"."trainers";