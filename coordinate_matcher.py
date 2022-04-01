import pandas as pd
import ast

formatted = pd.read_csv("data.csv")
locations = pd.read_csv("locations.csv")
coordinates = pd.read_csv("coordinates.csv", sep=";")

for index, row in locations.iterrows():
    coords = coordinates.loc[(coordinates["location"] == row["location"]) | (coordinates["geo_name"] == row["location"])]
    coords = coords["coordinates"]
    split_ = str(coords.iloc[0]).split(",")
    locations.loc[index, "location_lat"] = split_[0]
    locations.loc[index, "location_lng"] = split_[1]
    route_lat = []
    route_lng = []
    route = ast.literal_eval(row["route"])
    if route:
        for route_stop in route:
            coords = coordinates.loc[(coordinates["location"] == route_stop) | (coordinates["geo_name"] == route_stop)]
            coords = coords["coordinates"]
            try:
                split_ = str(coords.iloc[0]).split(",")
            except:
                pass
            locations.loc[index, "location_lat"] = str(locations.loc[index, "location_lat"]) + " " + str(split_[0])
            locations.loc[index, "location_lng"] = str(locations.loc[index, "location_lng"]) + " " + str(split_[1])

locations.index += 1
locations.to_csv("locations_matched.csv", index_label="id")
