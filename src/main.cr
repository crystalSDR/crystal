lib LibCrystalMain
  @[Raises]
  fun __crystal_main(argc : Int32, argv : UInt8**)
end

macro redefine_main(name = main)
  # :nodoc:
  fun main = {{name}}(argc : Int32, argv : UInt8**) : Int32
    %ex = nil
    %status = begin
      GC.init
      {{yield LibCrystalMain.__crystal_main(argc, argv)}}
      0
    rescue ex
      %ex = ex
      1
    end

    AtExitHandlers.run %status
    %ex.inspect_with_backtrace STDERR if %ex
    STDOUT.flush
    STDERR.flush
    %status
  end
end

{% unless flag?(:android) || flag?(:without_main) %}
  redefine_main do |main|
    \{{main}}
  end
{% end %}
