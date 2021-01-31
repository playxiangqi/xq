// Board
const ASPECT_RATIO = 1.1;
const FRAME_RATIO = 0.96;
const INNER_FRAME_RATIO = 0.85;

export const [FILE_MAX, RANK_MAX] = [8, 9];

// Piece
// export let size = 100;
// export let borderRadius = 50;
// export let outerRadius = 48;
// export let innerRadius = 43;
// export let strokeWidth = 2.2;

export class Dimensions {
  height: number;
  width: number;

  frameHeight: number;
  frameWidth: number;
  innerFrameHeight: number;
  innerFrameWidth: number;

  frameOffsetY: number;
  frameOffsetX: number;
  innerFrameOffsetY: number;
  innerFrameOffsetX: number;

  rankEnd: number;
  fileEnd: number;
  rankSpacing: number;
  fileSpacing: number;

  constructor(public readonly scale: number = 1.0) {
    this.height = 800 * this.scale;
    this.width = this.height / ASPECT_RATIO;

    this.frameHeight = this.height * FRAME_RATIO;
    this.frameWidth = this.width * FRAME_RATIO;
    this.innerFrameHeight = this.height * INNER_FRAME_RATIO;
    this.innerFrameWidth = this.width * INNER_FRAME_RATIO;

    this.frameOffsetY = (this.height - this.frameHeight) / 2;
    this.frameOffsetX = (this.width - this.frameWidth) / 2;
    this.innerFrameOffsetY =
      (this.height - this.innerFrameHeight) / 2 + this.frameOffsetY;
    this.innerFrameOffsetX =
      (this.width - this.innerFrameWidth) / 2 + this.frameOffsetX;

    this.rankEnd = this.height * INNER_FRAME_RATIO;
    this.fileEnd = this.width * INNER_FRAME_RATIO;
    this.rankSpacing = this.rankEnd / RANK_MAX;
    this.fileSpacing = this.fileEnd / FILE_MAX;
  }
  /**
   * clampPoint
   */
  private clampPoint(rank: number, file: number): [number, number] {
    return [
      Math.min(FILE_MAX, Math.max(0, Math.round(file))),
      Math.min(RANK_MAX, Math.max(Math.round(rank))),
    ];
  }

  // /**
  //  * pointToCoords
  //  */
  // public pointToCoords(rank: number, file: number): [number, number] {
  //   const [clampedFile, clampedRank] = this.clampPoint(file, rank);
  //   return [

  //   ]
  // }
}
