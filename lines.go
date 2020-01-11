package main

import (
	"github.com/faiface/pixel/pixelgl"
	"github.com/h8gi/canvas"
	"golang.org/x/image/colornames"
	"fmt"
	"math"
)

type Pixel struct {
	X float64
	Y float64
}

type Vertex struct {
	X float64
	Y float64
	Z float64
}

type Edge struct {
	v [2]int
	vis bool
}

type Plane struct {
	e [4]int
	vis bool
}

var vtab []Vertex
var etab []Edge
var ptab []Plane

func generate(n int) {
	var c float64

	etab = make([]Edge,0,1000)
	vtab = make([]Vertex,0,1000)
	ptab = make([]Plane,0,1000)
	c = float64(n-1)*50.0

	for i:=0 ; i<n ; i++ {
		for j:=0 ; j<n ; j++ {
			for k:=0 ; k<n ; k++ {
				xc := float64(i)*100.0 - c
				yc := float64(j)*100.0 - c
				zc := float64(k)*100.0 - c
				xmin := xc - 40.0
				xmax := xc + 40.0
				ymin := yc - 40.0
				ymax := yc + 40.0
				zmin := zc - 40.0
				zmax := zc + 40.0
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
				etab = append(etab,Edge{v:[2]int{vpos,vpos+1}})
				etab = append(etab,Edge{v:[2]int{vpos+2,vpos+3}})
				etab = append(etab,Edge{v:[2]int{vpos+4,vpos+5}})
				etab = append(etab,Edge{v:[2]int{vpos+6,vpos+7}})
				etab = append(etab,Edge{v:[2]int{vpos,vpos+2}})
				etab = append(etab,Edge{v:[2]int{vpos+1,vpos+3}})
				etab = append(etab,Edge{v:[2]int{vpos+4,vpos+6}})
				etab = append(etab,Edge{v:[2]int{vpos+5,vpos+7}})
				etab = append(etab,Edge{v:[2]int{vpos,vpos+4}})
				etab = append(etab,Edge{v:[2]int{vpos+1,vpos+5}})
				etab = append(etab,Edge{v:[2]int{vpos+2,vpos+6}})
				etab = append(etab,Edge{v:[2]int{vpos+3,vpos+7}})
				// plane
				ptab = append(ptab,Plane{e:[4]int{epos,epos+5,epos+1,epos+4}})
				ptab = append(ptab,Plane{e:[4]int{epos+2,epos+6,epos+3,epos+7}})
				ptab = append(ptab,Plane{e:[4]int{epos,epos+8,epos+2,epos+9}})
				ptab = append(ptab,Plane{e:[4]int{epos+1,epos+11,epos+3,epos+10}})
				ptab = append(ptab,Plane{e:[4]int{epos+9,epos+7,epos+11,epos+5}})
				ptab = append(ptab,Plane{e:[4]int{epos+8,epos+4,epos+10,epos+6}})
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

func perspective(v Vertex) (float64,float64) {
	v.Z -= 1000.0
	d := 200.0
	xx := v.X*d/(v.Z+d)
	yy := v.Y*d/(v.Z+d)
	return xx+160.0,yy+100.0
}

func main() {
	var alpha,beta,gamma float64
	var pixtab []Pixel

	generate(4)
	pixtab = make([]Pixel,len(vtab))
	fmt.Printf("len(vtab):%v\n",len(vtab))

	c := canvas.NewCanvas(&canvas.CanvasConfig{
		Width:     320,
		Height:    200,
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
		for i,v := range vtab {
			v.rotateX(alpha)
			v.rotateY(beta)
			v.rotateZ(gamma)
			xx,yy := perspective(v)
			pixtab[i].X = xx
			pixtab[i].Y = yy
		}
		for _,e := range etab {
			xs := pixtab[e.v[0]].X
			ys := pixtab[e.v[0]].Y
			xe := pixtab[e.v[1]].X
			ye := pixtab[e.v[1]].Y
			ctx.DrawLine(xs,ys,xe,ye)
		}
		ctx.Stroke()
		ctx.Pop()
		alpha += 0.017
		beta += 0.021
		gamma += 0.037

		if ctx.IsKeyPressed(pixelgl.KeyUp) {
			ctx.Push()
			ctx.SetColor(colornames.White)
			ctx.Clear()
			ctx.Pop()
		}
	})
}
