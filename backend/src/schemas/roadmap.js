const { z } = require('zod');

const ResourceSchema = z.string().min(1, 'Resource must not be empty');

const StageSchema = z.object({
  title: z.string().min(1, 'Stage title must not be empty'),
  resources: z
    .array(ResourceSchema, { required_error: 'Resources array is required' })
    .length(3, 'Each stage must have exactly 3 resources'),
});

const RoadmapOutputSchema = z.object({
  stages: z
    .array(StageSchema, { required_error: 'Stages array is required' })
    .min(5, 'Roadmap must have at least 5 stages')
    .max(8, 'Roadmap must have at most 8 stages'),
});

function validateRoadmapOutput(data) {
  const result = RoadmapOutputSchema.safeParse(data);
  if (!result.success) {
    const errors = result.error.errors.map((e) => e.message).join('; ');
    return { valid: false, errors };
  }
  return { valid: true, data: result.data };
}

module.exports = { validateRoadmapOutput, RoadmapOutputSchema };
