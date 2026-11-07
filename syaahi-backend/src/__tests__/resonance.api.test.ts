import { createResponseSchema, createReplySchema } from '../modules/resonance/resonance.schemas';

describe('Resonance Schemas & Validation', () => {
  describe('createResponseSchema', () => {
    it('accepts valid response content', () => {
      const result = createResponseSchema.safeParse({
        content: 'This poem resonated deeply with my memories of home.',
      });
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data.content).toBe('This poem resonated deeply with my memories of home.');
      }
    });

    it('trims leading and trailing whitespace', () => {
      const result = createResponseSchema.safeParse({
        content: '   A quiet thought   ',
      });
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data.content).toBe('A quiet thought');
      }
    });

    it('rejects empty content', () => {
      const result = createResponseSchema.safeParse({ content: '' });
      expect(result.success).toBe(false);
    });

    it('rejects whitespace-only content', () => {
      const result = createResponseSchema.safeParse({ content: '   ' });
      expect(result.success).toBe(false);
    });

    it('rejects content exceeding 280 characters', () => {
      const overLimit = 'a'.repeat(281);
      const result = createResponseSchema.safeParse({ content: overLimit });
      expect(result.success).toBe(false);
    });

    it('accepts content exactly 280 characters', () => {
      const exactLimit = 'a'.repeat(280);
      const result = createResponseSchema.safeParse({ content: exactLimit });
      expect(result.success).toBe(true);
    });
  });

  describe('createReplySchema', () => {
    it('accepts valid author reply content', () => {
      const result = createReplySchema.safeParse({
        content: 'Thank you for sharing your reflection.',
      });
      expect(result.success).toBe(true);
    });

    it('rejects empty author reply', () => {
      const result = createReplySchema.safeParse({ content: '   ' });
      expect(result.success).toBe(false);
    });

    it('rejects author reply over 280 characters', () => {
      const overLimit = 'b'.repeat(281);
      const result = createReplySchema.safeParse({ content: overLimit });
      expect(result.success).toBe(false);
    });
  });
});