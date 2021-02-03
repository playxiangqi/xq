const ASPECT_RATIO = 1.1;
const FRAME_RATIO = 0.975;
const INNER_FRAME_RATIO = 0.85;

export const [FILE_MAX, RANK_MAX] = [8, 9];

export class Dimensions {
  // Board
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

  maxY: number;
  maxX: number;

  // Piece
  pieceScale: number;
  pieceSize: number;
  pieceBorderRadius: number;
  pieceOuterRadius: number;
  pieceInnerRadius: number;
  pieceStrokeWidth: number;

  pieceOffsetY: number;
  pieceOffsetX: number;

  instance = this;

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
      (this.frameHeight - this.innerFrameHeight) / 2 + this.frameOffsetY;
    this.innerFrameOffsetX =
      (this.frameWidth - this.innerFrameWidth) / 2 + this.frameOffsetX;

    this.rankEnd = this.height * INNER_FRAME_RATIO;
    this.fileEnd = this.width * INNER_FRAME_RATIO;
    this.rankSpacing = this.rankEnd / RANK_MAX;
    this.fileSpacing = this.fileEnd / FILE_MAX;

    this.maxY = this.innerFrameOffsetY + this.rankEnd;
    this.maxX = this.innerFrameOffsetX + this.fileEnd;

    this.pieceScale = 0.675 * scale;
    this.pieceSize = 100 * this.pieceScale;
    this.pieceBorderRadius = 50 * this.pieceScale;
    this.pieceOuterRadius = 48 * this.pieceScale;
    this.pieceInnerRadius = 43 * this.pieceScale;
    this.pieceStrokeWidth = 2.5 * this.pieceScale;

    this.pieceOffsetY = this.innerFrameOffsetY - this.pieceBorderRadius * scale;
    this.pieceOffsetX = this.innerFrameOffsetX - this.pieceBorderRadius * scale;
  }
  /**
   * clampPoint
   */
  private clampPoint(rank: number, file: number): readonly [number, number] {
    return [
      Math.min(RANK_MAX, Math.max(Math.round(rank))),
      Math.min(FILE_MAX, Math.max(0, Math.round(file))),
    ] as const;
  }

  /**
   * clampCoords
   * @param y
   * @param x
   */
  public clampCoords(y: number, x: number): readonly [number, number] {
    return [
      Math.min(this.maxY, Math.max(0, y)),
      Math.min(this.maxX, Math.max(0, x)),
    ] as const;
  }

  /**
   * pointToCoords
   */
  public pointToCoords(rank: number, file: number): readonly [number, number] {
    const [clampedRank, clampedFile] = this.clampPoint(rank, file);
    return [
      this.pieceOffsetY + this.rankSpacing * clampedRank,
      this.pieceOffsetX + this.fileSpacing * clampedFile,
    ] as const;
  }

  /**
   * coordsToPoint
   */
  public coordsToPoint(y: number, x: number): readonly [number, number] {
    const [rank, file] = [
      (y - this.pieceOffsetY) / this.rankSpacing,
      (x - this.pieceOffsetX) / this.fileSpacing,
    ];
    return this.clampPoint(rank, file);
  }

  /**
   * snapCoords
   * @param y
   * @param x
   */
  public snapCoords(y: number, x: number): readonly [number, number] {
    const [clampedRank, clampedFile] = this.coordsToPoint(y, x);
    return this.pointToCoords(clampedRank, clampedFile);
  }
}
