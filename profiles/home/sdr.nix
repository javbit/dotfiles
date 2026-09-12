{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      # Receivers, all built with the rtl-sdr source.
      sdrpp
      gqrx
      sdrangel

      # GNU Radio with gr-osmosdr so Companion has an RTL-SDR source block.
      (gnuradio.override { extraPackages = [ gnuradio.pkgs.osmosdr ]; })

      # CLI: rtl_test, rtl_fm, rtl_tcp, rtl_power ...
      rtl-sdr
      # Decodes 433/868/915 MHz sensors, weather stations, TPMS, etc.
      rtl_433
    ];
  };
}
