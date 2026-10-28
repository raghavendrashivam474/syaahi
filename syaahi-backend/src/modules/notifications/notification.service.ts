import { prisma } from '../../config/prisma';

/**
 * Creates POEM_PUBLISHED notification records for all eligible recipients.
 *
 * Eligibility rules (ADR-025 approved):
 *   - User has a NotificationPreference row with newPoemAlerts = true
 *   - User is NOT the poem author (no self-notification)
 *
 * Duplicate protection:
 *   - createMany with skipDuplicates: true
 *   - Relies on @@unique([recipientId, poemId, type]) constraint
 *
 * Failure handling (best-effort, synchronous):
 *   - Notification failure does NOT roll back the already-persisted poem
 *   - Failures are logged to console.error (visible in Vercel function logs)
 *   - No automatic retry — this is a documented limitation
 *
 * @param poemId  - The ID of the newly published poem
 * @param authorId - The ID of the poem's author (excluded from recipients)
 */
export const createPublicationNotifications = async (
  poemId: string,
  authorId: string
): Promise<void> => {
  try {
    const optedInUsers = await prisma.notificationPreference.findMany({
      where: {
        newPoemAlerts: true,
        userId: { not: authorId },
      },
      select: { userId: true },
    });

    if (optedInUsers.length === 0) {
      return;
    }

    const notifications = optedInUsers.map((user) => ({
      recipientId: user.userId,
      poemId,
      type: 'POEM_PUBLISHED' as const,
    }));

    const result = await prisma.notification.createMany({
      data: notifications,
      skipDuplicates: true,
    });

    if (result.count < notifications.length) {
      const skipped = notifications.length - result.count;
      console.log(
        `[N3] Notifications: ${result.count} created, ${skipped} duplicates skipped (poem ${poemId})`
      );
    }
  } catch (error) {
    // Best-effort: the poem is already persisted.
    // Log the failure for observability but do not throw.
    console.error(
      `[N3] Failed to create publication notifications for poem ${poemId}:`,
      error
    );
  }
};