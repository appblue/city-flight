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
	s = 2.0 * float64(winy)/float64(n)
	bs = s*0.8
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

func (e *Edge) getpixel(t float64) (float64,float64) {
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

func (p *Plane) setvis() {

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
	alpha += 0.017
	beta += 0.021
	gamma += 0.037
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
				xs,ys := e.getpixel(f.S)
				xe,ye := e.getpixel(f.E)
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
		for _,e := range etab {
			for _,f := range e.Vis {
				xs,ys := e.getpixel(f.S)
				xe,ye := e.getpixel(f.E)
				fmt.Fprintf(file,"Line: %v,%v,%v,%v\n",int(xs),int(ys),int(xe),int(ye))
			}
		}
	}
	file.Close()
}

func main() {
	if len(os.Args)>=3 {
		winx = 320
		winy = 200
		generate(2)
		fmt.Printf("len(vtab):%v\n",len(vtab))
		count,err := strconv.Atoi(os.Args[2])
		if err==nil {
			writedata(os.Args[1],count)
		}
	} else {
		generate(2)
		animate()
	}
}
