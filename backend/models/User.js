const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true, default: 'User' },
  avatar: { type: String, default: null },
}, { timestamps: true });

userSchema.virtual('id').get(function () {
  return this._id.toString();
});
userSchema.set('toJSON', { virtuals: true });
userSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('User', userSchema);
