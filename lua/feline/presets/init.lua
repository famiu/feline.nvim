-- Use lazy_require to only load the preset that's are being used
local lazy_require = require('feline.utils').lazy_require

return {
    default = lazy_require('feline.presets.default'),
    noicon = lazy_require('feline.presets.noicon')
}
