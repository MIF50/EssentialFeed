# EssentialFeed

[![CI](https://github.com/MIF50/EssentialFeed/actions/workflows/CI.yml/badge.svg)](https://github.com/MIF50/EssentialFeed/actions/workflows/CI.yml)


## Image Feed Feature Specs

### Story: Customer requests to see their image feed

### Narrative #1

```
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed
```

### Narrative #2

```
As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends
```

#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is less than seven days old
 When the customer requests to see the feed
 Then the app should display the latest feed saved
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is seven days old or more
 When the customer requests to see the feed
 Then the app should display an error message
Given the customer doesn't have connectivity
  And the cache is empty
 When the customer requests to see the feed
 Then the app should display an error message
```

## Use Cases

### Load Feed From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Feed" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

---


 ### Load Feed Image Data From Remote Use Case

 #### Data:
 - URL

 #### Primary course (happy path):
 1. Execute "Load Image Data" command with above data.
 2. System downloads data from the URL.
 3. System validates downloaded data.
 4. System delivers image data.

 #### Cancel course:
 1. System does not deliver image data nor error.

 #### Invalid data – error course (sad path):
 1. System delivers invalid data error.

 #### No connectivity – error course (sad path):
 1. System delivers connectivity error.

 ---


 ### Load Feed Image Data From Cache Use Case

 #### Data:
 - URL

 #### Primary course (happy path):
 1. Execute "Load Image Data" command with above data.
 2. System retrieves data from the cache.
 3. System delivers cached image data.

 #### Cancel course:
 1. System does not deliver image data nor error.

 #### Retrieval error course (sad path):
 1. System delivers error.

 #### Empty cache course (sad path):
 1. System delivers no image data.

 ---

