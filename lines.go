package main

import (
//	"github.com/faiface/pixel/pixelgl"
	"github.com/h8gi/canvas"
	"golang.org/x/image/colornames"
	"fmt"
	"math"
	"os"
	"strconv"
)

var winx = 800 // 320
var winy = 600 // 200

type Frag struct {
	S float64
	E float64
}

type Vertex struct {
	X float64
	Y float64
	Z float64
	XX float64
	YY float64
}

type Edge struct {
	V [2]int
	Vis []Frag
}

type Plane struct {
	E [4]int
	Vis bool
}

var vtab []Vertex
var vrtab []Vertex
var etab []Edge
var ptab []Plane

func generate(n int) {
	var c float64
	var s float64
	var bs float64

	vtab = make([]Vertex,0,1000)
	vrtab = make([]Vertex,1000)
	etab = make([]Edge,0,1000)
	ptab = make([]Plane,0,1000)
	s = 2.2 * float64(winy)/float64(n)
	bs = s*0.6
	c = float64(n-1)*s/2.0

	for i:=0 ; i<n ; i++ {
		for j:=0 ; j<n ; j++ {
			for k:=0 ; k<n ; k++ {
				xc := float64(i)*s - c
				yc := float64(j)*s - c
				zc := float64(k)*s - c
				xmin := xc - bs/2.0
				xmax := xc + bs/2.0
				ymin := yc - bs/2.0
				ymax := yc + bs/2.0
				zmin := zc - bs/2.0
				zmax := zc + bs/2.0
				vpos := len(vtab)
				epos := len(etab)
				// vertex
				vtab = append(vtab,Vertex{X:xmin,Y:ymin,Z:zmin})
				vtab = append(vtab,Vertex{X:xmax,Y:ymin,Z:zmin})
				vtab = append(vtab,Vertex{X:xmin,Y:ymin,Z:zmax})
				vtab = append(vtab,Vertex{X:xmax,Y:ymin,Z:zmax})
				vtab = append(vtab,Vertex{X:xmin,Y:ymax,Z:zmin})
				vtab = append(vtab,Vertex{X:xmax,Y:ymax,Z:zmin})
				vtab = append(vtab,Vertex{X:xmin,Y:ymax,Z:zmax})
				vtab = append(vtab,Vertex{X:xmax,Y:ymax,Z:zmax})
				// edge
				etab = append(etab,Edge{V:[2]int{vpos,vpos+1}})
				etab = append(etab,Edge{V:[2]int{vpos+2,vpos+3}})
				etab = append(etab,Edge{V:[2]int{vpos+4,vpos+5}})
				etab = append(etab,Edge{V:[2]int{vpos+6,vpos+7}})
				etab = append(etab,Edge{V:[2]int{vpos,vpos+2}})
				etab = append(etab,Edge{V:[2]int{vpos+1,vpos+3}})
				etab = append(etab,Edge{V:[2]int{vpos+4,vpos+6}})
				etab = append(etab,Edge{V:[2]int{vpos+5,vpos+7}})
				etab = append(etab,Edge{V:[2]int{vpos,vpos+4}})
				etab = append(etab,Edge{V:[2]int{vpos+1,vpos+5}})
				etab = append(etab,Edge{V:[2]int{vpos+2,vpos+6}})
				etab = append(etab,Edge{V:[2]int{vpos+3,vpos+7}})
				// plane
				ptab = append(ptab,Plane{E:[4]int{epos,epos+5,epos+1,epos+4}})
				ptab = append(ptab,Plane{E:[4]int{epos+2,epos+6,epos+3,epos+7}})
				ptab = append(ptab,Plane{E:[4]int{epos,epos+8,epos+2,epos+9}})
				ptab = append(ptab,Plane{E:[4]int{epos+1,epos+11,epos+3,epos+10}})
				ptab = append(ptab,Plane{E:[4]int{epos+9,epos+7,epos+11,epos+5}})
				ptab = append(ptab,Plane{E:[4]int{epos+8,epos+4,epos+10,epos+6}})
			}
		}
	}
}

func (v *Vertex) rotateX(angle float64) {
	zz := v.Z * math.Cos(angle) + v.Y * math.Sin(angle)
	yy := v.Y * math.Cos(angle) - v.Z * math.Sin(angle)
	v.Y = yy
	v.Z = zz
}

func (v *Vertex) rotateY(angle float64) {
	xx := v.X * math.Cos(angle) + v.Z * math.Sin(angle)
	zz := v.Z * math.Cos(angle) - v.X * math.Sin(angle)
	v.X = xx
	v.Z = zz
}

func (v *Vertex) rotateZ(angle float64) {
	xx := v.X * math.Cos(angle) + v.Y * math.Sin(angle)
	yy := v.Y * math.Cos(angle) - v.X * math.Sin(angle)
	v.X = xx
	v.Y = yy
}

func (v *Vertex) projection() {
	z := v.Z - float64(winy) * 5.0 // 1000.0
	d := float64(winy) // 200.0
	v.XX = v.X*d/(z+d) + float64(winx)/2.0
	v.YY = v.Y*d/(z+d) + float64(winy)/2.0
}

func (e *Edge) getpixel3d(t float64) (float64,float64) {
	vs := vrtab[e.V[0]]
	ve := vrtab[e.V[1]]
	v := Vertex {
		X: vs.X + (ve.X - vs.X) * t,
		Y: vs.Y + (ve.Y - vs.Y) * t,
		Z: vs.Z + (ve.Z - vs.Z) * t,
	}
	v.projection()
	return v.XX,v.YY
}

func (e *Edge) getpixel2d(t float64) (float64,float64) {
	vs := vrtab[e.V[0]]
	ve := vrtab[e.V[1]]
	return vs.XX + (ve.XX - vs.XX) * t,vs.YY + (ve.YY - vs.YY) * t
}

func (e *Edge) removefragment(tmin,tmax float64) {
	if tmin<0.0 {
		tmin = 0.0
	}
	if tmax>1.0 {
		tmax = 1.0
	}
	if e.Vis==nil || (tmin==0.0 && tmax==1.0) {
		e.Vis = nil
		return
	} else {
		frags := len(e.Vis)
		if frags>0 {
			if tmin <= e.Vis[0].S && tmax >= e.Vis[frags-1].E {
				e.Vis = nil
				return
			}
			firsttoremove:=frags
			lasttoremove:=0
			for i,_ := range e.Vis {
				if e.Vis[i].S < tmin && e.Vis[i].E > tmax { // insert new
					e.Vis = e.Vis[:frags+1] // increase len
					for j:=frags ; j>i ; j-- {
						e.Vis[j] = e.Vis[j-1]
					}
					e.Vis[i].E = tmin
					e.Vis[i+1].S = tmax
					return
				}
				if tmin <= e.Vis[i].S && tmax >= e.Vis[i].E {
					if i<firsttoremove {
						firsttoremove = i
					}
					if i>lasttoremove {
						lasttoremove = i
					}
				}
				if tmin > e.Vis[i].S && tmin < e.Vis[i].E {
					e.Vis[i].E = tmin
				}
				if tmax > e.Vis[i].S && tmax < e.Vis[i].E {
					e.Vis[i].S = tmax
				}
			}
			fr := firsttoremove
			ls := lasttoremove+1
			if fr<=ls {
				if fr==0 {
					e.Vis = e.Vis[ls:]
					return
				}
				if ls==frags {
					e.Vis = e.Vis[:fr]
					return
				}
				for j:=0 ; j<frags-ls ; j++ {
					e.Vis[fr+j] = e.Vis[ls+j]
				}
				e.Vis = e.Vis[:frags-(ls-fr)]
			}
		}
/*
		frags := len(e.Vis)
		vis := make([]Frag,frags+1)
		for _,f := range e.Vis {
			if f.E <= tmin || f.S >= tmax { // outside
				vis = append(vis,f)
			} else {
				if f.S < tmin {
					vis = append(vis,Frag{S:f.S,E:tmin})
				}
				if f.E > tmax {
					vis = append(vis,Frag{S:tmax,E:f.E})
				}
			}
		}
		e.Vis = vis
*/
	}
}

func resetvis() {
	for i,_ := range etab {
		etab[i].Vis = nil
	}
	for i,_ := range ptab {
		ptab[i].Vis = false
	}
}

func hiddenedges() {
	var vc,v1,v2 int
	resetvis()
	for i,_ := range ptab {
		e1 := etab[ptab[i].E[0]].V
		e2 := etab[ptab[i].E[1]].V
		if e1[0]==e2[0] {
			vc = e1[0]
			v1 = e1[1]
			v2 = e2[1]
		} else if e1[0]==e2[1] {
			vc = e1[0]
			v1 = e1[1]
			v2 = e2[0]
		} else if e1[1]==e2[0] {
			vc = e1[1]
			v1 = e1[0]
			v2 = e2[1]
		} else { // e1[1]==e2[1]
			vc = e1[1]
			v1 = e1[0]
			v2 = e2[0]
		}
		xx1 := vrtab[v1].XX - vrtab[vc].XX
		yy1 := vrtab[v1].YY - vrtab[vc].YY
		xx2 := vrtab[v2].XX - vrtab[vc].XX
		yy2 := vrtab[v2].YY - vrtab[vc].YY
		if (xx1*yy2 < xx2*yy1) {
			ptab[i].Vis = true
			for _,j := range ptab[i].E {
				if etab[j].Vis==nil {
					etab[j].Vis = make([]Frag,1,10)
					etab[j].Vis[0].S = 0.0
					etab[j].Vis[0].E = 1.0
				}
			}
		}
	}
	for i,_ := range etab {
		ezmid := ( vrtab[etab[i].V[0]].Z + vrtab[etab[i].V[1]].Z ) / 2.0
		for _,p := range ptab {
			if p.Vis {
				pzmid := 0.0
				for _,j := range p.E {
					if i==j {
						pzmid = -10000000.0
						break
					} else {
						pzmid += vrtab[etab[j].V[0]].Z
						pzmid += vrtab[etab[j].V[1]].Z
					}
				}
				pzmid /= float64(len(p.E) * 2)
				if pzmid > ezmid { // plane is in front of the edge
					AXX := vrtab[etab[i].V[0]].XX
					AYY := vrtab[etab[i].V[0]].YY
					BXX := vrtab[etab[i].V[1]].XX
					BYY := vrtab[etab[i].V[1]].YY
//					edx = vrtab[etab[i].V[1]].XX - vrtab[etab[i].V[0]].XX
//					edy = vrtab[etab[i].V[1]].YY - vrtab[etab[i].V[0]].YY
					tmin := 1.0
					tmax := 0.0
					for _,j := range p.E {
						CXX := vrtab[etab[j].V[0]].XX
						CYY := vrtab[etab[j].V[0]].YY
						DXX := vrtab[etab[j].V[1]].XX
						DYY := vrtab[etab[j].V[1]].YY
						delim := (BXX-AXX)*(DYY-CYY) - (BYY-AYY)*(DXX-CXX)
						t1 := ((CXX-AXX)*(DYY-CYY) - (CYY-AYY)*(DXX-CXX)) / delim
						t2 := ((CXX-AXX)*(BYY-AYY) - (CYY-AYY)*(BXX-AXX)) / delim
						if t2 >= 0.0 && t2 <= 1.0 {
							if t1 < tmin {
								tmin = t1
							}
							if t1 > tmax {
								tmax = t1
							}
						}
//						pdx = vrtab[etab[j].V[1]].XX - vrtab[etab[j].V[0]].XX
//						pdy = vrtab[etab[j].V[1]].YY - vrtab[etab[j].V[0]].YY

					}
					if tmin<tmax && tmax>0.0 && tmin<1.0 {
						etab[i].removefragment(tmin,tmax)
					}
				}
			}
		}
		// etab[i].removefragment(0.33,0.66)
	}
}

var alpha,beta,gamma float64

func nextframe() {
	for i,v := range vtab {
		v.rotateX(alpha)
		v.rotateY(beta)
		v.rotateZ(gamma)
		v.projection()
		vrtab[i] = v
	}

	alpha += 0.020943951023931952
	beta += 0.041887902047863905
	gamma += 0.06283185307179587
//	alpha += 0.017
//	beta += 0.021
//	gamma += 0.037
}

func animate() {
	c := canvas.NewCanvas(&canvas.CanvasConfig{
		Width:     winx,
		Height:    winy,
		FrameRate: 30,
		Title:     "Hello Canvas!",
	})

	c.Setup(func(ctx *canvas.Context) {
		ctx.SetColor(colornames.White)
		ctx.Clear()
		ctx.SetColor(colornames.Green)
		ctx.SetLineWidth(1)
	})

	c.Draw(func(ctx *canvas.Context) {
		ctx.Push()
		ctx.SetColor(colornames.Black)
		ctx.Clear()
		ctx.SetColor(colornames.White)
		nextframe()
		hiddenedges()
		for _,e := range etab {
			for _,f := range e.Vis {
				xs,ys := e.getpixel2d(f.S)
				xe,ye := e.getpixel2d(f.E)
				ctx.DrawLine(xs,ys,xe,ye)
			}
		}
		ctx.Stroke()
		ctx.Pop()
/*
		if ctx.IsKeyPressed(pixelgl.KeyUp) {
			ctx.Push()
			ctx.SetColor(colornames.White)
			ctx.Clear()
			ctx.Pop()
		}
*/
	})
}

func writedata(filename string,count int) {
	file, err := os.Create(filename)
	if err != nil {
		fmt.Println(err)
		file.Close()
		return
	}
	for i:=0 ; i<count ; i++ {
		fmt.Fprintf(file,"Frame: %v\n",i)
		nextframe()
		hiddenedges()
		l := 0
		for _,e := range etab {
			for _,f := range e.Vis {
				xs,ys := e.getpixel2d(f.S)
				xe,ye := e.getpixel2d(f.E)
				fmt.Fprintf(file,"Line: %v,%v,%v,%v\n",int(xs),int(ys),int(xe),int(ye))
				l++
			}
		}
		fmt.Printf("Frame: %v ; lines: %v\n",i,l)
	}
	file.Close()
}

func main() {
	if len(os.Args)>=3 {
		winx = 320
		winy = 200
		generate(4)
		fmt.Printf("len(vtab):%v\n",len(vtab))
		count,err := strconv.Atoi(os.Args[2])
		if err==nil {
			writedata(os.Args[1],count)
		}
	} else {
		winx = 320
		winy = 200
		generate(4)
		animate()
	}
}
