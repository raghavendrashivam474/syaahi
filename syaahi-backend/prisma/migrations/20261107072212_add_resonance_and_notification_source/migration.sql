-- AlterEnum: Add RESONANCE_RESPONSE and AUTHOR_REPLY to NotificationType
ALTER TYPE "NotificationType" ADD VALUE 'RESONANCE_RESPONSE';
ALTER TYPE "NotificationType" ADD VALUE 'AUTHOR_REPLY';

-- Drop the old unique constraint on Notification
ALTER TABLE "Notification" DROP CONSTRAINT IF EXISTS "Notification_recipientId_poemId_type_key";

-- Add sourceId column to Notification
ALTER TABLE "Notification" ADD COLUMN "sourceId" TEXT;

-- Add new unique constraint with sourceId
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_recipientId_poemId_type_sourceId_key" UNIQUE ("recipientId", "poemId", "type", "sourceId");

-- CreateTable: ResonanceResponse
CREATE TABLE "ResonanceResponse" (
    "id" TEXT NOT NULL,
    "poemId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "content" VARCHAR(280) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ResonanceResponse_pkey" PRIMARY KEY ("id")
);

-- CreateTable: ResonanceReply
CREATE TABLE "ResonanceReply" (
    "id" TEXT NOT NULL,
    "responseId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "content" VARCHAR(280) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ResonanceReply_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ResonanceResponse_poemId_idx" ON "ResonanceResponse"("poemId");
CREATE INDEX "ResonanceResponse_userId_idx" ON "ResonanceResponse"("userId");

-- CreateIndex (unique)
CREATE UNIQUE INDEX "ResonanceReply_responseId_key" ON "ResonanceReply"("responseId");

-- AddForeignKey
ALTER TABLE "ResonanceResponse" ADD CONSTRAINT "ResonanceResponse_poemId_fkey" FOREIGN KEY ("poemId") REFERENCES "Poem"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ResonanceResponse" ADD CONSTRAINT "ResonanceResponse_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ResonanceReply" ADD CONSTRAINT "ResonanceReply_responseId_fkey" FOREIGN KEY ("responseId") REFERENCES "ResonanceResponse"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ResonanceReply" ADD CONSTRAINT "ResonanceReply_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;