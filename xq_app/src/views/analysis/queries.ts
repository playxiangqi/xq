export const GET_GAME_BOARD_STATES_QUERY = (gameID: number | string) => `
  query getGameBoardStates {
    game(id: "${gameID}") {
      info {
        redPlayer
        blackPlayer
        result
        event
        date
        openingCode
        openingName
        moves
      }
      boards {
        state {
          ch
          side
          rank
          file
        }
        prevPoint {
          ch
          side
          rank
          file
        }
        nextPoint {
          ch
          side
          rank
          file
        }
      }
    }
  }
`;

export const GET_OPENINGS_QUERY = `
  query getOpenings {
    openings {
      id
      name
    }
  }
`;

export const SEARCH_GAMES_QUERY = `
  query searchGames($filter: SearchGameFilter!) {
    games(filter: $filter) {
      id
      redPlayer
      blackPlayer
      result
      event
      date
      openingCode
      openingName
      turnCount
    }
  }
`;
