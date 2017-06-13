module Hooky
  module Elasticsearch
    CONFIG_DEFAULTS = {
      # global settings
      before_deploy:          {type: :array, of: :string, default: []},
      after_deploy:           {type: :array, of: :string, default: []},
      hook_ref:               {type: :string, default: "stable"},

      cluster_name:           {type: :string, default: payload[:component] ? payload[:component][:uid] : "elasticsearch"}
    }
  end
end
