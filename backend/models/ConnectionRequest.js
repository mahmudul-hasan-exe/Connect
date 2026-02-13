const mongoose = require('mongoose');

const connectionRequestSchema = new mongoose.Schema(
  {
    fromUser: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    toUser: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
  },
  { timestamps: true }
);

connectionRequestSchema.index({ fromUser: 1, toUser: 1 }, { unique: true });
connectionRequestSchema.index({ toUser: 1, status: 1 });

module.exports = mongoose.model('ConnectionRequest', connectionRequestSchema);
