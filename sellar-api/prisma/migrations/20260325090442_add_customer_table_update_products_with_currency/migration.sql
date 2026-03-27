/*
  Warnings:

  - You are about to drop the column `firstSeenAt` on the `customers` table. All the data in the column will be lost.
  - You are about to drop the column `lastSeenAt` on the `customers` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "customers" DROP COLUMN "firstSeenAt",
DROP COLUMN "lastSeenAt",
ADD COLUMN     "billingAddress" TEXT,
ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "currency" TEXT NOT NULL DEFAULT 'USD',
ADD COLUMN     "lastPurchaseAt" TIMESTAMP(3),
ADD COLUMN     "name" TEXT;

-- AlterTable
ALTER TABLE "products" ADD COLUMN     "currency" TEXT NOT NULL DEFAULT 'USD';
