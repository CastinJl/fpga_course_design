// Sine waveform conversion from a shared DDS phase.
// The output is an unsigned 12-bit DAC code centered at 2048.
module sine_wave_gen(
    input              [31:0] phase,
    output             [11:0] wave_data
);

    // The top 9 phase bits select one of 512 positions in a full cycle.
    wire [8:0] addr = phase[31:23];
    wire [6:0] lut_addr = addr[6:0];

    // One quarter of the sine table is mirrored into the other quadrants.
    reg [11:0] sin_quarter [0:127];
    initial begin
        sin_quarter[0]=0;    sin_quarter[1]=25;   sin_quarter[2]=50;   sin_quarter[3]=75;
        sin_quarter[4]=100;  sin_quarter[5]=125;  sin_quarter[6]=151;  sin_quarter[7]=176;
        sin_quarter[8]=201;  sin_quarter[9]=226;  sin_quarter[10]=250; sin_quarter[11]=275;
        sin_quarter[12]=300; sin_quarter[13]=325; sin_quarter[14]=350; sin_quarter[15]=374;
        sin_quarter[16]=399; sin_quarter[17]=423; sin_quarter[18]=448; sin_quarter[19]=472;
        sin_quarter[20]=496; sin_quarter[21]=521; sin_quarter[22]=545; sin_quarter[23]=569;
        sin_quarter[24]=593; sin_quarter[25]=617; sin_quarter[26]=641; sin_quarter[27]=664;
        sin_quarter[28]=688; sin_quarter[29]=712; sin_quarter[30]=735; sin_quarter[31]=758;
        sin_quarter[32]=782; sin_quarter[33]=805; sin_quarter[34]=828; sin_quarter[35]=851;
        sin_quarter[36]=874; sin_quarter[37]=896; sin_quarter[38]=919; sin_quarter[39]=941;
        sin_quarter[40]=964; sin_quarter[41]=986; sin_quarter[42]=1008;sin_quarter[43]=1030;
        sin_quarter[44]=1052;sin_quarter[45]=1073;sin_quarter[46]=1095;sin_quarter[47]=1116;
        sin_quarter[48]=1137;sin_quarter[49]=1158;sin_quarter[50]=1179;sin_quarter[51]=1200;
        sin_quarter[52]=1220;sin_quarter[53]=1240;sin_quarter[54]=1261;sin_quarter[55]=1281;
        sin_quarter[56]=1300;sin_quarter[57]=1320;sin_quarter[58]=1339;sin_quarter[59]=1359;
        sin_quarter[60]=1378;sin_quarter[61]=1397;sin_quarter[62]=1415;sin_quarter[63]=1434;
        sin_quarter[64]=1452;sin_quarter[65]=1470;sin_quarter[66]=1488;sin_quarter[67]=1506;
        sin_quarter[68]=1523;sin_quarter[69]=1540;sin_quarter[70]=1557;sin_quarter[71]=1574;
        sin_quarter[72]=1591;sin_quarter[73]=1607;sin_quarter[74]=1623;sin_quarter[75]=1639;
        sin_quarter[76]=1654;sin_quarter[77]=1670;sin_quarter[78]=1685;sin_quarter[79]=1700;
        sin_quarter[80]=1714;sin_quarter[81]=1729;sin_quarter[82]=1743;sin_quarter[83]=1757;
        sin_quarter[84]=1770;sin_quarter[85]=1783;sin_quarter[86]=1796;sin_quarter[87]=1809;
        sin_quarter[88]=1821;sin_quarter[89]=1833;sin_quarter[90]=1845;sin_quarter[91]=1856;
        sin_quarter[92]=1867;sin_quarter[93]=1878;sin_quarter[94]=1888;sin_quarter[95]=1899;
        sin_quarter[96]=1908;sin_quarter[97]=1918;sin_quarter[98]=1927;sin_quarter[99]=1936;
        sin_quarter[100]=1945;sin_quarter[101]=1953;sin_quarter[102]=1961;sin_quarter[103]=1969;
        sin_quarter[104]=1976;sin_quarter[105]=1983;sin_quarter[106]=1989;sin_quarter[107]=1996;
        sin_quarter[108]=2002;sin_quarter[109]=2007;sin_quarter[110]=2013;sin_quarter[111]=2018;
        sin_quarter[112]=2022;sin_quarter[113]=2027;sin_quarter[114]=2030;sin_quarter[115]=2034;
        sin_quarter[116]=2037;sin_quarter[117]=2040;sin_quarter[118]=2042;sin_quarter[119]=2044;
        sin_quarter[120]=2045;sin_quarter[121]=2046;sin_quarter[122]=2047;sin_quarter[123]=2047;
        sin_quarter[124]=2047;sin_quarter[125]=2047;sin_quarter[126]=2047;sin_quarter[127]=2047;
    end

    reg [11:0] full_sine;
    always @(*) begin
        case (addr[8:7])
            2'b00: full_sine = 12'd2048 + sin_quarter[lut_addr];
            2'b01: full_sine = 12'd2048 + sin_quarter[7'd127 - lut_addr];
            2'b10: full_sine = 12'd2048 - sin_quarter[lut_addr];
            2'b11: full_sine = 12'd2048 - sin_quarter[7'd127 - lut_addr];
        endcase
    end

    assign wave_data = full_sine;

endmodule
