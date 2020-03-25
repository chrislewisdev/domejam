import "math" for Point
import "./src/constants" for Constants

/**
 * Contains various useful functions for working with numbers/vectors.
 */
class MathUtils {
  // Creates a 'cycler' - a function that returns a value cycling between min/max every time it is called
  // This is useful for handling some timer/counter values without having to add logic for each one
  // cycleDuration can be used to create a delay between moving from one value to the next to slow it down
  // stepSize controls how much the value should change by each time
  static getCycler(min, max, cycleDuration, stepSize) {
    var value = min
    var timer = cycleDuration
    return Fn.new {
      timer = timer - 1
      if (timer <= 0) {
        value = value + stepSize
        if (value > max) value = min
        timer = cycleDuration
      }
      return value
    }
  }

  // Converts a co-ordinate in our grid (e.g. 2, 0) to an on-screen co-ordinate (e.g. 48, 0)
  static cellsToPixels(v) {
    return Point.new(v.x * Constants.tileSize, (v.y + 1) * Constants.tileSize)
  }

  // Takes a vector and returns a value of it moved towards the destination by no greater than stepLength distance
  static moveTowards(origin, destination, stepLength) {
    if ((destination - origin).length <= stepLength) return destination

    return origin + (destination - origin).unit * stepLength
  }
}