module.exports = {
  PORT: parseInt(process.env.PORT, 10) || 3000,
  SUPABASE_URL: process.env.SUPABASE_URL || 'https://your-project.supabase.co',
};
