#ifndef __gchsp2xcsm__
#module __gchsp2xcsm__
#defcfunc local __gcsm_getptrofprevra
	mref hspctx, 68
	// HSPHED取得
	dupptr hsphed, hspctx(0), 96, 4
	// 関数呼び出し元のCSポインタ取得
	dupptr mcs, hspctx(207) - 16 - 76, 4
	// CSポインタからCSを取得
	dupptr cs, mcs, hsphed(5) - (hspctx(2) - mcs)
	return varptr(cs)
#deffunc local __gcsm_setptrofprevra int prm_0
	mref hspctx, 68
	// HSPHED取得
	dupptr hsphed, hspctx(0), 96, 4
	// 関数呼び出し元のCSポインタ取得
	dupptr mcs, hspctx(207) - 16 - 76, 4
	lpoke mcs,0,prm_0
	return
#deffunc local __gcsm_sethandler
onerror gosub *__gcsm_handler
return
*__gcsm_handler
__gcsm_funcendptr=__gcsm_getptrofprevra()-6
dupptr __gcsm_opcode,__gcsm_funcendptr,0x7fffffff,2
__gcsm_prefixflag=0
repeat
if ((lpeek(__gcsm_opcode,cnt) & 0x20002000) = 0x20002000){continue cnt+2}
if (wpeek(__gcsm_opcode,cnt) &0x2000){__gcsm_prefixflag++:if __gcsm_prefixflag>=2{__gcsm_funcendptr+=cnt:break}:__gcsm_ptrofemuinst=(__gcsm_funcendptr+cnt)}
continue cnt+2
loop
sdim __gcsm_bytecodebuffer,65536
__gcsm_prefixflag=0
dim __gcsm_instattr,2,32
__gcsm_instcnt=0
dupptr __gcsm_opcode,__gcsm_ptrofemuinst,0x7fffffff,2
repeat
if (wpeek(__gcsm_opcode,cnt) &0x2000){__gcsm_prefixflag++:if __gcsm_prefixflag>=2{break}}
if wpeek(__gcsm_opcode,cnt)&0x8000{
	__gcsm_contofinst=lpeek(__gcsm_opcode,cnt+2)
}else{
	__gcsm_contofinst=wpeek(__gcsm_opcode,cnt+2)
}
__gcsm_instattr(0,__gcsm_instcnt)=(wpeek(__gcsm_opcode,cnt)&0xFFFF)
__gcsm_instattr(1,__gcsm_instcnt)=lpeek(__gcsm_contofinst,0)
__gcsm_instcnt++
if wpeek(__gcsm_opcode,cnt)&0x8000{
continue cnt+6
}else{
continue cnt+4
}
continue cnt+2
loop
__gcsm_instcnt2=0
__gcsm_commerenabled=1
//translating user var
repeat __gcsm_instcnt-1
if (__gcsm_instattr(0,cnt+1)&0xFFF)=0 & __gcsm_instattr(1,cnt+1)='('{__gcsm_commerenabled--}
if (__gcsm_instattr(0,cnt+1)&0xFFF)=0 & __gcsm_instattr(1,cnt+1)=')'{__gcsm_commerenabled++}
if cnt>=1 & __gcsm_commerenabled=1{__gcsm_comma=cnt+1:break}
if cnt=0{
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,(__gcsm_instattr(0,cnt+1)&(0xFFFF-0x4000))|0x2000
}else{
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,(__gcsm_instattr(0,cnt+1)&(0xFFFF-0x2000))
}
__gcsm_instcnt2+=2
if __gcsm_instattr(0,cnt+1)&0x8000{
	lpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(1,cnt+1)
	__gcsm_instcnt2+=4
}else{
	wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(1,cnt+1)
	__gcsm_instcnt2+=2
}
loop
//EQUAL(=)
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,0
__gcsm_instcnt2+=2
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,8
__gcsm_instcnt2+=2
//opcode
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(0,0)&(0xFFFF-0x2000)
__gcsm_instcnt2+=2
if __gcsm_instattr(0,0)&0x8000{
	lpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(1,0)
	__gcsm_instcnt2+=4
}else{
	wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(1,0)
	__gcsm_instcnt2+=2
}
//(
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,0
__gcsm_instcnt2+=2
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,'('
__gcsm_instcnt2+=2
__gcsm_commerenabled=1
//translating user func
repeat __gcsm_instcnt-__gcsm_comma
if (__gcsm_instattr(0,cnt+__gcsm_comma)&0xFFF)=0 & __gcsm_instattr(1,cnt+__gcsm_comma)='('{__gcsm_commerenabled--}
if (__gcsm_instattr(0,cnt+__gcsm_comma)&0xFFF)=0 & __gcsm_instattr(1,cnt+__gcsm_comma)=')'{__gcsm_commerenabled++}
if cnt>=1 & ((__gcsm_instattr(0,cnt+__gcsm_comma)&0x4000)=0 & (__gcsm_instattr(0,cnt+__gcsm_comma+1)&0x4000)=0) & __gcsm_commerenabled=1{__gcsm_finnish=cnt+__gcsm_comma:break}
if cnt=0{
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,(__gcsm_instattr(0,cnt+__gcsm_comma)&(0xFFFF-0x1000-0x4000))
}else{
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,(__gcsm_instattr(0,cnt+__gcsm_comma)&(0xFFFF-0x1000-0x2000))
}
__gcsm_instcnt2+=2
if __gcsm_instattr(0,cnt+__gcsm_comma)&0x8000{
	lpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(1,cnt+__gcsm_comma)
	__gcsm_instcnt2+=4
}else{
	wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,__gcsm_instattr(1,cnt+__gcsm_comma)
	__gcsm_instcnt2+=2
}
loop
//)
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,0
__gcsm_instcnt2+=2
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,')'
__gcsm_instcnt2+=2
//return
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,15|0x2000
__gcsm_instcnt2+=2
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,2
__gcsm_instcnt2+=2
//stop
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,15|0x2000
__gcsm_instcnt2+=2
wpoke __gcsm_bytecodebuffer,__gcsm_instcnt2,0x11
__gcsm_instcnt2+=2
ldim __gcsm_lbl,1
lpoke __gcsm_lbl,0,varptr(__gcsm_bytecodebuffer)
gosub __gcsm_lbl
__gcsm_setptrofprevra __gcsm_funcendptr
return
#global
__gcsm_sethandler@__gchsp2xcsm__
#endif
