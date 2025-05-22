# Band Music Calendar

[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/DBaAVOQl)

## Link

https://software-studio-d7d9fa70f610.herokuapp.com/

## MVP

The MVP is that we have an events feed sorted by the most recent events to the most future events, where any user is able to upload a new event.

## Project Functionality

### Calendar

Weekly calendar where you can see events (can go back/forward a day)

#### Possible Formats

- **List view** (swipe up/down)
- **Card View** (Swipe left/right)
- **Grid view** like Physical Calendar, one box represents a day

### Information Needed

#### Band Information

- Artist name
- Photo
- Short Bio

#### Event information

- Date
- Time
- Location

## Spotify API Integration

This application uses the Spotify API to search for and retrieve band information. When creating or editing events, you can search for bands using the Spotify database, which will automatically populate the band information in our database.

### Features

- Search for artists directly from the event creation/edit form
- Automatically fetch artist information including image and bio
- Display artist popularity metrics
- Limit search results to 5 most relevant artists

### Setup

To use the Spotify API integration:

1. Go to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/)
2. Create a new application to get your credentials
3. Create a `.env` file in the root directory with the following format (see SPOTIFY_ENV_EXAMPLE.md):

```
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
```

## Team Members

Kevin Wang, Irving Peng, Ronghe Chen, Zhuoqun Wang
