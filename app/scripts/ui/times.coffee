
seconds = 1000
minutes = 60 * seconds

exports.every_30_secs = (30 * seconds)
exports.every_3_minutes = (3 * minutes)

exports.very_frequently = (10 * seconds)
exports.frequently = exports.every_30_secs
exports.less_frequently = exports.every_3_minutes
