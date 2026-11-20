-- CreateTable: Draft
CREATE TABLE IF NOT EXISTS "Draft" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "title" TEXT,
    "content" TEXT NOT NULL,
    "language" "Language" NOT NULL DEFAULT 'ENGLISH',
    "emotion" "Emotion",
    "theme" TEXT,
    "isPublished" BOOLEAN NOT NULL DEFAULT false,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Draft_pkey" PRIMARY KEY ("id")
);

-- Add draftId to Poem if not exists
ALTER TABLE "Poem" ADD COLUMN IF NOT EXISTS "draftId" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX IF NOT EXISTS "Poem_draftId_key" ON "Poem"("draftId");
CREATE INDEX IF NOT EXISTS "Draft_ownerId_idx" ON "Draft"("ownerId");
CREATE INDEX IF NOT EXISTS "Draft_ownerId_updatedAt_idx" ON "Draft"("ownerId", "updatedAt");

-- AddForeignKey
ALTER TABLE "Draft" ADD CONSTRAINT "Draft_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Poem" ADD CONSTRAINT "Poem_draftId_fkey" FOREIGN KEY ("draftId") REFERENCES "Draft"("id") ON DELETE SET NULL ON UPDATE CASCADE;
