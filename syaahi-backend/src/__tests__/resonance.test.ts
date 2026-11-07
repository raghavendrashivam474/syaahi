import assert from 'node:assert';
import { createResponseSchema, createReplySchema } from '../modules/resonance/resonance.schemas';

console.log('🧪 Running Resonance Schema & Validation Tests...\n');

// 1. Valid response content
{
  const result = createResponseSchema.safeParse({
    content: 'This poem resonated deeply with my memories of home.',
  });
  assert.strictEqual(result.success, true, 'Valid response should pass');
  if (result.success) {
    assert.strictEqual(
      result.data.content,
      'This poem resonated deeply with my memories of home.'
    );
  }
  console.log('✅ Passed: Valid response content accepted');
}

// 2. Trim whitespace
{
  const result = createResponseSchema.safeParse({
    content: '   A quiet thought   ',
  });
  assert.strictEqual(result.success, true, 'Whitespace should be trimmed');
  if (result.success) {
    assert.strictEqual(result.data.content, 'A quiet thought');
  }
  console.log('✅ Passed: Whitespace trimmed correctly');
}

// 3. Reject empty response
{
  const result = createResponseSchema.safeParse({ content: '' });
  assert.strictEqual(result.success, false, 'Empty response should fail');
  console.log('✅ Passed: Empty response rejected');
}

// 4. Reject whitespace-only response
{
  const result = createResponseSchema.safeParse({ content: '   ' });
  assert.strictEqual(result.success, false, 'Whitespace-only response should fail');
  console.log('✅ Passed: Whitespace-only response rejected');
}

// 5. Reject content over 280 chars
{
  const overLimit = 'a'.repeat(281);
  const result = createResponseSchema.safeParse({ content: overLimit });
  assert.strictEqual(result.success, false, 'Content over 280 chars should fail');
  console.log('✅ Passed: Content over 280 chars rejected');
}

// 6. Accept exact 280 chars
{
  const exactLimit = 'a'.repeat(280);
  const result = createResponseSchema.safeParse({ content: exactLimit });
  assert.strictEqual(result.success, true, 'Exact 280 chars should pass');
  console.log('✅ Passed: Content exact 280 chars accepted');
}

// 7. Author reply validation
{
  const validReply = createReplySchema.safeParse({
    content: 'Thank you for sharing your reflection.',
  });
  assert.strictEqual(validReply.success, true, 'Valid author reply should pass');

  const emptyReply = createReplySchema.safeParse({ content: '   ' });
  assert.strictEqual(emptyReply.success, false, 'Empty author reply should fail');

  const longReply = createReplySchema.safeParse({ content: 'b'.repeat(281) });
  assert.strictEqual(longReply.success, false, 'Over-limit author reply should fail');

  console.log('✅ Passed: Author reply schema validation');
}

console.log('\n🎉 All Resonance Schema Tests Passed Successfully!\n');