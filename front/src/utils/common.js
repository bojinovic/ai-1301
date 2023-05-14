const GAME_SCENE_DIMENSIONS = {
  width: 800,
  height: 500,
};

const delay = (delayInms) => {
  return new Promise((resolve) => setTimeout(resolve, delayInms));
};

export { GAME_SCENE_DIMENSIONS, delay };
