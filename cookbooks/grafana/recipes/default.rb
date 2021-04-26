
#
# Cookbook:: grafana
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.

grafana_install "grafana"

service "grafana-server" do
  action [:enable, :start]
  subscribes :restart, ["template[/etc/grafana/grafana.ini]", "template[/etc/grafana/ldap.toml]"], :delayed
end


