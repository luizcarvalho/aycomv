# Pagy initializer file (7.0.6)
# Customize this file as you need

# Validating the configuration
# Pagy::DEFAULT.freeze

# Instance variables
# Pagy::DEFAULT[:page]   = 1
# Pagy::DEFAULT[:items]  = 20
# Pagy::DEFAULT[:outset] = 0

# Other Variables
# Pagy::DEFAULT[:size]       = 7
# Pagy::DEFAULT[:cycle]      = false
# Pagy::DEFAULT[:steps]      = false
# Pagy::DEFAULT[:limit]      = 100 # max items per page

# Extras
# See https://ddnexus.github.io/pagy/docs/extras
require "pagy/extras/bootstrap"
require "pagy/extras/overflow"

Pagy::DEFAULT[:overflow] = :last_page
