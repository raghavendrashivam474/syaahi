import { prisma } from '../../config/prisma';

/**
 * Creates POEM_PUBLISHED notification records for all eligible recipients.
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
    console.error(
      `[N3] Failed to create publication notifications for poem ${poemId}:`,
      error
    );
  }
};

/**
 * Creates a RESONANCE_RESPONSE notification for the poem author.
 * Skips self-notifications if responder is the author.
 */
export const createResonanceNotification = async (
  poemId: string,
  authorId: string,
  responderId: string,
  responseId: string
): Promise<void> => {
  if (authorId === responderId) return;

  try {
    await prisma.notification.create({
      data: {
        recipientId: authorId,
        poemId,
        type: 'RESONANCE_RESPONSE',
        sourceId: responseId,
      },
    });
  } catch (error) {
    console.error(
      `[UX-06] Failed to create resonance notification for poem ${poemId}:`,
      error
    );
  }
};

/**
 * Creates an AUTHOR_REPLY notification for the original responder.
 * Skips self-notifications if author is the responder.
 */
export const createReplyNotification = async (
  poemId: string,
  responderId: string,
  authorId: string,
  replyId: string
): Promise<void> => {
  if (responderId === authorId) return;

  try {
    await prisma.notification.create({
      data: {
        recipientId: responderId,
        poemId,
        type: 'AUTHOR_REPLY',
        sourceId: replyId,
      },
    });
  } catch (error) {
    console.error(
      `[UX-06] Failed to create reply notification for poem ${poemId}:`,
      error
    );
  }
};