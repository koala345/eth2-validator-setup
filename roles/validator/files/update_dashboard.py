# This script updates the prysm-grafana-dashboard and resets the uid and id fields.
# This is required to be able to import the dashboard using the API.

import json

dashboard_file = open("dashboard.json", "r")
json_object = json.load(dashboard_file)
dashboard_file.close()

json_object['id'] = None
json_object['uid'] = "eth2_dashboard"

out_file = open("dashboard_upd.json", "w")
json.dump(json_object, out_file, indent = 2)
out_file.close()
