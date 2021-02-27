export const GET_OPENINGS_QUERY = `
  query getOpenings {
    openings {
      id
      name
    }
  }
`;

export const SEARCH_GAMES_QUERY = `
  query searchGames(
    $redPlayer: String
    $blackPlayer: String
    $openingCode: String
    $result: String
    $limit: Int
  ) {
    games(
      redPlayer: $redPlayer
      blackPlayer: $blackPlayer
      openingCode: $openingCode
      result: $result
      limit: $limit
    ) {
      id
      redPlayer
      blackPlayer
      result
      event
      date
      openingCode
      openingName
    }
  }
`;
