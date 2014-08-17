//http://code.google.com/p/google-authenticator/source/browse/libpam/totp.html
function totp(K,t) {
  function T(x){ var y=0x100000000;return(y+(x|0))%y; }
  function sha1(C) {
    function L(x,b){return T(x<<b|x>>>32-b);}
    var l=C.length,D=C.concat([T(1<<31)]),V=0x67452301,W=0xEFCDAB89,X=0x98BADCFE,Y=0x10325476,Z=0xC3D2E1F0;
    do D.push(0);
    while(D.length+1&15);
    D.push(32*l);
    while (D.length){
      var E=D.splice(0,16),a=V,b=W,c=X,d=Y,e=Z,f,i=12;
      function I(x){var t=T(L(a,5)+f+e+k+E[x]);e=d;d=c;c=L(b,30);b=a;a=t;}
      for(;++i<77;)E.push(L(E[i]^E[i-5]^E[i-11]^E[i-13],1));
      k=0x5A827999;for(i=0;i<20;I(i++))f=T(b&c|~b&d);
      k=0x6ED9EBA1;for(;i<40;I(i++))f=T(b^c^d);
      k=0x8F1BBCDC;for(;i<60;I(i++))f=T(b&c|b&d|c&d);
      k=0xCA62C1D6;for(;i<80;I(i++))f=T(b^c^d);
      V=T(V+a);W=T(W+b);X=T(X+c);Y=T(Y+d);Z=T(Z+e);}
    return[V,W,X,Y,Z];
  }
  var k=[],l=[],i=0,j=0,c=0;
  for (;i<K.length;){
    c=c*32+'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567'.
      indexOf(K.charAt(i++).toUpperCase());
    if((j+=5)>31)k.push(T(Math.floor(c/(1<<(j-=32))))),c&=31;}
  j&&k.push(c*(1<<(j-32)));while(k.length<16)k.push(0);
  for(i=0;i<16;++i)l.push(T(0x6A6A6A6A^(k[i]=T(k[i]^0x5C5C5C5C))));
  var s=sha1([k].concat(sha1(l.concat([0,t])))),o=s[4]&0xF;
  return ((s[o>>2]<<8*(o&3)|(o&3?s[(o>>2)+1]>>>8*(4-o&3):0))&-1>>>1)%1000000;
}

function getcode(secret) {
  var k=secret.replace(/[^ABCDEFGHIJKLMNOPQRSTUVWXYZ234567]/gi, '');
  var t=Math.floor(new Date().getTime()/30000);
  var code=totp(k,t);
  if (String(code).length < 6) {
      code = "0" + code
  }

  return code;
}
