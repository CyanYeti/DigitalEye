import 'dart:ui';
import 'dart:math';

class ColorPalette {
  static const Color bright1 = Color.fromARGB(255, 255, 213, 164);
  static const Color bright2 = Color.fromARGB(255, 255, 218, 174);
  static const Color bright3 = Color.fromARGB(255, 255, 222, 184);
  static const Color bright4 = Color.fromARGB(255, 255, 227, 194);
  static const Color bright5 = Color.fromARGB(255, 255, 232, 204);
  static const Color bright6 = Color.fromARGB(255, 255, 236, 214);

  static const Color dark1 = Color.fromARGB(255, 50, 62, 77);
  static const Color dark2 = Color.fromARGB(255, 70, 81, 95);
  static const Color dark3 = Color.fromARGB(255, 91, 101, 113);
  static const Color dark4 = Color.fromARGB(255, 113, 121, 132);
  static const Color dark5 = Color.fromARGB(255, 135, 142, 152);
  static const Color dark6 = Color.fromARGB(255, 158, 164, 171);
}

// Color is a complex topic. Color stores a sRGB value normalized 0..1
// Most of the time this should be converted to at least linear RGB for
// any operations such as blending
// Lab is best to compare colors as it should be similar to perception
class ColorUtils {
  static double linearized(int c) {
    final normalized = c / 255.0;
    if (normalized <= 0.040449936) {
      return normalized / 12.92 * 100.0;
    } else {
      return pow((normalized + 0.055) / 1.055, 2.4).toDouble() * 100.0;
    }
  }

  static double linearizedFromNormalized(double c) {
    if (c <= 0.040449936) {
      return c / 12.92 * 100.0;
    } else {
      return pow((c + 0.055) / 1.055, 2.4).toDouble() * 100.0;
    }
  }

  static int delinearizedTosRGBInt(double c) {
    final normalized = c / 100.0;
    var delinearized = 0.0;
    if (normalized <= 0.0031308) {
      delinearized = normalized * 12.92;
    } else {
      delinearized = 1.055 * pow(normalized, 1.0 / 2.4).toDouble() - 0.055;
    }
    return clampDouble((delinearized * 255.0), 0, 255).round();
  }

  // Convert RGB to XYZ with D65/2 degrees as reference white as D65 is RW for sRGB
  static List<double> normsRGBToXYZ(double r, double g, double b) {
    if (r > 0.04045) {
      r = pow((r + 0.055) / 1.055, 2.4).toDouble();
    } else {
      r = r / 12.92;
    }
    if (g > 0.04045) {
      g = pow((g + 0.055) / 1.055, 2.4).toDouble();
    } else {
      g = g / 12.92;
    }
    if (b > 0.04045) {
      b = pow((b + 0.055) / 1.055, 2.4).toDouble();
    } else {
      b = b / 12.92;
    }

    r = r * 100;
    g = g * 100;
    b = b * 100;

    double X = r * 0.4124 + g * 0.3576 + b * 0.1805;
    double Y = r * 0.2126 + g * 0.7152 + b * 0.0722;
    double Z = r * 0.0193 + g * 0.1192 + b * 0.9505;

    return [X, Y, Z];
  }

  static List<double> XYZtoLAB(double X, double Y, double Z) {
    X = X / 95.047;
    Y = Y / 100;
    Z = Z / 108.883;

    if (X > 0.008856) {
      X = pow(X, 1 / 3).toDouble();
    } else {
      X = (7.787 * X) + (16 / 116);
    }
    if (Y > 0.008856) {
      Y = pow(Y, 1 / 3).toDouble();
    } else {
      Y = (7.787 * Y) + (16 / 116);
    }
    if (Z > 0.008856) {
      Z = pow(Z, 1 / 3).toDouble();
    } else {
      Z = (7.787 * Z) + (16 / 116);
    }
    double L = (116 * Y) - 16;
    double a = 500 * (X - X);
    double b = 200 * (Y - Z);

    return [L, a, b];
  }

  // expect 0..255
  static sRGBtoLAB(double r, double g, double b) {
    List<double> XYZ = normsRGBToXYZ(r / 255, g / 255, b / 255);
    return XYZtoLAB(XYZ[0], XYZ[1], XYZ[2]);
  }
}
