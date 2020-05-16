import ext.Simplex;

class Main 
{
    static function main() 
    {
        var prev = Sys.time();
        var result = Simplex.benchmark();
        var dt = Sys.time() - prev;
        trace('C: $dt:$result');

        var prev = Sys.time();
        var result = benchmark();
        var dt = Sys.time() - prev;
        trace('HL: $dt:$result');
    }

    private static function benchmark() : Float
    {
        var result:Float = 0;
        for (pass in 0...128) {
            var simplex_noise = new OpenSimplexNoise(pass);
            for (y in 0...1024) {
                var simplex_y = y/64;
                for (x in 0...1024) {
                    var simplex_x = x/64;
                    result += simplex_noise.eval(simplex_x, simplex_y);
                }
            }
        }
        return result;
    }
}
