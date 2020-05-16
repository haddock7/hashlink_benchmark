import haxe.Int64;

class OpenSimplexNoise
{
    static inline var STRETCH_CONSTANT_2D:Float = -0.211324865405187;    //(1/Math.sqrt(2+1)-1)/2;
    static inline var SQUISH_CONSTANT_2D:Float = 0.366025403784439;      //(Math.sqrt(2+1)-1)/2;
    static inline var NORM_CONSTANT_2D:Float = 47;

    var perm : Array<Int> = [];

    //Gradients for 2D. They approximate the directions to the
    //vertices of an octagon from the center.
    static var gradients_2D: Array<Int> = 
    [
        5,  2,    2,  5,
        -5,  2,   -2,  5,
        5, -2,    2, -5,
        -5, -2,   -2, -5,
    ];

   // ----------------------------------------------------------------------------
   public function new(seed : Int)
    {
        var lseed:Int64 = seed;

        this.perm.resize(256);

        var source : Array<Int> = [];
        source.resize(256);
    
        for (i in 0...256) {
            source[i] = i;
        }

        var constant1 = Int64.make(0x5851F42D, 0x4C957F2D);
        var constant2 = Int64.make(0x14057B7E, 0xF767814F);
    
        lseed = lseed * constant1 + constant2;
        lseed = lseed * constant1 + constant2;
        lseed = lseed * constant1 + constant2;

        var i = 255;
        while (i >= 0) {
            lseed = lseed * constant1 + constant2;
            var r:Int = ((lseed + 31) % (i + 1)).low;
            if (r < 0) {
                r += (i + 1);
            }
            this.perm[i] = source[r];
            source[r] = source[i];

            i--;
        }
    }

    // ----------------------------------------------------------------------------
    public function eval(x : Float, y : Float) : Float
    {
        //Place input coordinates onto grid.
        var stretchOffset = (x + y) * STRETCH_CONSTANT_2D;
        var xs = x + stretchOffset;
        var ys = y + stretchOffset;

        //Floor to get grid coordinates of rhombus (stretched square) super-cell origin.
        var xsb = fastFloor(xs);
        var ysb = fastFloor(ys);

        //Skew out to get actual coordinates of rhombus origin. We'll need these later.
        var squishOffset = (xsb + ysb) * SQUISH_CONSTANT_2D;
        var xb = xsb + squishOffset;
        var yb = ysb + squishOffset;

        //Compute grid coordinates relative to rhombus origin.
        var xins = xs - xsb;
        var yins = ys - ysb;

        //Sum those together to get a value that determines which region we're in.
        var inSum = xins + yins;

        //Positions relative to origin point.
        var dx0 = x - xb;
        var dy0 = y - yb;

        //We'll be defining these inside the next block and using them afterwards.
        var dx_ext, dy_ext;
        var xsv_ext, ysv_ext;

        var value:Float = 0;

        //Contribution (1,0)
        var dx1 = dx0 - 1 - SQUISH_CONSTANT_2D;
        var dy1 = dy0 - 0 - SQUISH_CONSTANT_2D;
        var attn1 = 2 - dx1 * dx1 - dy1 * dy1;
        if (attn1 > 0) {
            attn1 *= attn1;
            value += attn1 * attn1 * extrapolate(xsb + 1, ysb + 0, dx1, dy1);
        }

        //Contribution (0,1)
        var dx2 = dx0 - 0 - SQUISH_CONSTANT_2D;
        var dy2 = dy0 - 1 - SQUISH_CONSTANT_2D;
        var attn2 = 2 - dx2 * dx2 - dy2 * dy2;
        if (attn2 > 0) {
            attn2 *= attn2;
            value += attn2 * attn2 * extrapolate(xsb + 0, ysb + 1, dx2, dy2);
        }

        if (inSum <= 1) { //We're inside the triangle (2-Simplex) at (0,0)
        var zins = 1 - inSum;
            if (zins > xins || zins > yins) { //(0,0) is one of the closest two triangular vertices
                if (xins > yins) {
                    xsv_ext = xsb + 1;
                    ysv_ext = ysb - 1;
                    dx_ext = dx0 - 1;
                    dy_ext = dy0 + 1;
                }
                else {
                    xsv_ext = xsb - 1;
                    ysv_ext = ysb + 1;
                    dx_ext = dx0 + 1;
                    dy_ext = dy0 - 1;
                }
            }
            else { //(1,0) and (0,1) are the closest two vertices.
                xsv_ext = xsb + 1;
                ysv_ext = ysb + 1;
                dx_ext = dx0 - 1 - 2 * SQUISH_CONSTANT_2D;
                dy_ext = dy0 - 1 - 2 * SQUISH_CONSTANT_2D;
            }
        }
        else { //We're inside the triangle (2-Simplex) at (1,1)
            var zins = 2 - inSum;
            if (zins < xins || zins < yins) { //(0,0) is one of the closest two triangular vertices
                if (xins > yins) {
                    xsv_ext = xsb + 2;
                    ysv_ext = ysb + 0;
                    dx_ext = dx0 - 2 - 2 * SQUISH_CONSTANT_2D;
                    dy_ext = dy0 + 0 - 2 * SQUISH_CONSTANT_2D;
                }
                else {
                    xsv_ext = xsb + 0;
                    ysv_ext = ysb + 2;
                    dx_ext = dx0 + 0 - 2 * SQUISH_CONSTANT_2D;
                    dy_ext = dy0 - 2 - 2 * SQUISH_CONSTANT_2D;
                }
            }
            else { //(1,0) and (0,1) are the closest two vertices.
                dx_ext = dx0;
                dy_ext = dy0;
                xsv_ext = xsb;
                ysv_ext = ysb;
            }
            xsb += 1;
            ysb += 1;
            dx0 = dx0 - 1 - 2 * SQUISH_CONSTANT_2D;
            dy0 = dy0 - 1 - 2 * SQUISH_CONSTANT_2D;
        }

        //Contribution (0,0) or (1,1)
        var attn0 = 2 - dx0 * dx0 - dy0 * dy0;
        if (attn0 > 0) {
            attn0 *= attn0;
            value += attn0 * attn0 * extrapolate(xsb, ysb, dx0, dy0);
        }

        //Extra Vertex
        var attn_ext = 2 - dx_ext * dx_ext - dy_ext * dy_ext;
        if (attn_ext > 0) {
            attn_ext *= attn_ext;
            value += attn_ext * attn_ext * extrapolate(xsv_ext, ysv_ext, dx_ext, dy_ext);
        }

        return value / NORM_CONSTANT_2D;
    }

    // ----------------------------------------------------------------------------
    inline static private function fastFloor(x : Float) : Int {
        var xi = Std.int(x);
        return x < xi ? xi - 1 : xi;
    }

    // ----------------------------------------------------------------------------
    private function extrapolate(xsb : Int, ysb : Int, dx : Float, dy : Float) : Float
    {
        var index = this.perm[(this.perm[xsb & 0xFF] + ysb) & 0xFF] & 0x0E;
        return OpenSimplexNoise.gradients_2D[index] * dx + OpenSimplexNoise.gradients_2D[index + 1] * dy;
    }

}