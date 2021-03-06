import pandas as pd
import ast

formatted = pd.read_csv("../data.csv")
locations = pd.read_csv("locations.csv")
coordinates = pd.read_csv("coordinates.csv", sep=";")

for index, row in locations.iterrows():
    # compare location to both columns containing potential matches in coordinates.csv and save the row
    match = coordinates.loc[(coordinates["location"] == row["location"]) | (coordinates["geo_name"] == row["location"])]
    coords = match["coordinates"]  # get coordinates from row
    try:  # this prints the current row if a location couldn't be matched
        split_ = str(coords.iloc[0]).split(",")
    except:
        print(row)
        pass
    locations.loc[index, "location_lat"] = split_[0]  # save coordinates of starting location
    locations.loc[index, "location_lng"] = split_[1]
    route_lat = []
    route_lng = []
    route = ast.literal_eval(row["route"])  # convert the stringified list to an actual list object
    if route:  # continue if route exists
        for route_stop in route:
            match = coordinates.loc[(coordinates["location"] == route_stop) | (coordinates["geo_name"] == route_stop)]
            coords = match["coordinates"]
            try:
                split_ = str(coords.iloc[0]).split(",")
            except:
                print(row)
                pass
            # add new coordinates to current path
            locations.loc[index, "location_lat"] = str(locations.loc[index, "location_lat"]) + " " + str(split_[0])
            locations.loc[index, "location_lng"] = str(locations.loc[index, "location_lng"]) + " " + str(split_[1])

locations.index += 1
locations.to_csv("locations_matched.csv", index_label="id")
