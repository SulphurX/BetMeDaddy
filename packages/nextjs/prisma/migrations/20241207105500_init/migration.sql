-- CreateTable
CREATE TABLE "Pods" (
    "id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "deadline" TIMESTAMP(3) NOT NULL,
    "description" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "token" TEXT NOT NULL,
    "rewardAmount" INTEGER NOT NULL,
    "rewards" TEXT[],
    "skills" TEXT[],
    "type" TEXT NOT NULL,
    "requirements" TEXT[],
    "totalPaymentMade" INTEGER NOT NULL,
    "totalWinnersSelected" INTEGER NOT NULL,
    "isWinnerAnnounced" BOOLEAN NOT NULL,
    "region" TEXT NOT NULL,
    "pocSocial" TEXT NOT NULL,
    "timeToComplete" TEXT NOT NULL,
    "winners" TEXT[],
    "sponsors" TEXT[],

    CONSTRAINT "Pods_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Pods_title_key" ON "Pods"("title");
