-- CreateEnum
CREATE TYPE "SocialPlatform" AS ENUM ('FACEBOOK', 'INSTAGRAM', 'WHATSAPP', 'TIKTOK');

-- CreateTable
CREATE TABLE "social_connections" (
    "id" TEXT NOT NULL,
    "vendorId" TEXT NOT NULL,
    "platform" "SocialPlatform" NOT NULL,
    "accessToken" TEXT NOT NULL,
    "refreshToken" TEXT,
    "tokenExpiresAt" TIMESTAMP(3),
    "platformUserId" TEXT,
    "platformUsername" TEXT,
    "pageId" TEXT,
    "pageName" TEXT,
    "scopes" TEXT[],
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "connectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "social_connections_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "social_connections_vendorId_platform_key" ON "social_connections"("vendorId", "platform");

-- AddForeignKey
ALTER TABLE "social_connections" ADD CONSTRAINT "social_connections_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES "vendors"("id") ON DELETE CASCADE ON UPDATE CASCADE;
