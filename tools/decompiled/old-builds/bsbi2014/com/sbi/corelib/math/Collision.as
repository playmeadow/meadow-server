package com.sbi.corelib.math
{
   import flash.geom.Point;
   
   public class Collision
   {
      
      public function Collision()
      {
         super();
      }
      
      public static function segIntersection(p1:Point, p2:Point, p3:Point, p4:Point) : Point
      {
         var bx:Number = p2.x - p1.x;
         var by:Number = p2.y - p1.y;
         var dx:Number = p4.x - p3.x;
         var dy:Number = p4.y - p3.y;
         var b_dot_d_perp:Number = bx * dy - by * dx;
         if(b_dot_d_perp == 0)
         {
            return null;
         }
         var cx:Number = p3.x - p1.x;
         var cy:Number = p3.y - p1.y;
         var t:Number = (cx * dy - cy * dx) / b_dot_d_perp;
         if(t < 0 || t > 1)
         {
            return null;
         }
         var u:Number = (cx * by - cy * bx) / b_dot_d_perp;
         if(u < 0 || u > 1)
         {
            return null;
         }
         return new Point(p1.x + t * bx,p1.y + t * by);
      }
      
      public static function circleHitCircle(c1:Point, r1:Number, c2:Point, r2:Number) : Boolean
      {
         var dif:Point = c2.subtract(c1);
         var d:Number = dif.x * dif.x + dif.y * dif.y;
         return Boolean(d < (r1 + r2) * (r1 + r2));
      }
      
      public static function pointHitCircle(p:Point, cp:Point, cr:Number) : Boolean
      {
         var diff:Point = p.subtract(cp);
         var distSqrd:Number = diff.x * diff.x + diff.y * diff.y;
         return Boolean(distSqrd < cr * cr);
      }
      
      public static function movingCircleVsRay(cir:Point, radius:Number, vel:Point, tCol:Number, p1:Point, p2:Point) : Number
      {
         var d:Number = NaN;
         var Oz:Number = NaN;
         var t:Number = NaN;
         var ox:Number = NaN;
         var oy:Number = NaN;
         var norm:Number = NaN;
         var s:Number = NaN;
         var tColInfinite:Number = NaN;
         var vHitPosInfinite:Point = null;
         var vSegHitInfiniteP1:Point = null;
         var vSegHitInfiniteP2:Point = null;
         var vSeg:Point = p2.subtract(p1);
         var RC:Point = cir.subtract(p1);
         var D:Point = new Point();
         var raycos:Point = new Point(vel.x * tCol,vel.y * tCol);
         var velMag:Number = vel.x * vel.y;
         var nz:Number = raycos.x * vSeg.y - raycos.y * vSeg.x;
         var ln:Number = nz;
         if(ln == 0)
         {
            d = RC.x * vSeg.x + RC.y * vSeg.y;
            D.x = RC.x - vSeg.x * d;
            D.y = RC.y - vSeg.y * d;
            tCol = 0;
            return D.x * D.y <= radius ? -1 : 1;
         }
         nz /= ln;
         d = 0;
         if(d <= radius)
         {
            Oz = RC.x * vSeg.y - RC.y * vSeg.x;
            t = -(Oz * nz) / ln;
            ox = -(nz * vSeg.y);
            oy = nz * vSeg.x;
            norm = ox * ox + oy * oy;
            if(Boolean(norm))
            {
               norm = Math.sqrt(norm);
               ox /= norm;
               oy /= norm;
            }
            s = Math.abs(radius / (raycos.x * ox + raycos.y * oy));
            if(t < -s)
            {
               return -1;
            }
            if(t - s > 1)
            {
               return -1;
            }
            tColInfinite = t - s < 0 ? 0 : t - s;
            vHitPosInfinite = new Point(cir.x + vel.x * tColInfinite,cir.y + vel.y * tColInfinite);
            vSegHitInfiniteP1 = vHitPosInfinite.subtract(p1);
            vSegHitInfiniteP2 = vHitPosInfinite.subtract(p2);
            if(vSegHitInfiniteP1.x * vSeg.x + vSegHitInfiniteP1.y * vSeg.y < 0)
            {
               return Ray_Vs_Sphere(cir,vel,tCol,p1,radius);
            }
            if(vSegHitInfiniteP2.x * vSeg.x + vSegHitInfiniteP2.y * vSeg.y > 0)
            {
               return Ray_Vs_Sphere(cir,vel,tCol,p2,radius);
            }
            return tColInfinite;
         }
         return -1;
      }
      
      public static function rayHitCircle(c:Point, radius:Number, p1:Point, p2:Point) : Boolean
      {
         var dif:Point = c.subtract(p1);
         var dir:Point = p2.subtract(p1);
         var t:Number = (dif.x * dir.x + dif.y * dir.y) / (dir.x * dir.x + dir.y * dir.y);
         if(t < 0)
         {
            t = 0;
         }
         if(t > 1)
         {
            t = 1;
         }
         var closest:Point = new Point(p1.x + t * dir.x,p1.y + t * dir.y);
         var dist:Point = c.subtract(closest);
         var distsqr:Number = dist.x * dist.x + dist.y * dist.y;
         return Boolean(distsqr <= radius * radius);
      }
      
      public static function Ray_Vs_Sphere(RayPos:Point, RayVel:Point, fRange:Number, S:Point, radius:Number) : Number
      {
         var x2:Number = NaN;
         var v_seg_mag:Number = NaN;
         var v_seg_mag_inv:Number = NaN;
         var v_seg_unit:Point = null;
         var x1:Number = NaN;
         var tCol:Number = NaN;
         var radius_sq:Number = radius * radius;
         var v_sphere:Point = S.subtract(RayPos);
         var v_sphere_mag_sq:Number = v_sphere.x * v_sphere.x + v_sphere.y * v_sphere.y;
         var v_seg:Point = new Point(RayVel.x * fRange,RayVel.y * fRange);
         var P2:Point = v_seg.add(RayPos);
         var test_2a:Number = v_seg.x * v_sphere.x + v_seg.y * v_sphere.y;
         var v_sphere2:Point = S.subtract(P2);
         var test_2b:Number = v_seg.x * v_sphere2.x + v_seg.y * v_sphere2.y;
         var test_2bb:Number = (v_sphere2.x + v_sphere2.y) * (v_sphere2.x + v_sphere2.y);
         var cpz:Number = v_seg.x * v_sphere.y - v_seg.y * v_sphere.x;
         var seg_dist_sq:Number = cpz * cpz;
         var v_seg_mag_sq:Number = v_seg.x * v_seg.x + v_seg.y * v_seg.y;
         if(test_2a > 0 && (test_2b < 0 || test_2bb < radius_sq) && seg_dist_sq < radius_sq * v_seg_mag_sq && v_seg_mag_sq > 0.00001)
         {
            x2 = Math.sqrt(radius_sq - seg_dist_sq / v_seg_mag_sq);
            v_seg_mag = Math.sqrt(v_seg_mag_sq);
            v_seg_mag_inv = 1 / v_seg_mag;
            v_seg_unit = new Point(v_seg.x * v_seg_mag_inv,v_seg.y * v_seg_mag_inv);
            x1 = v_seg_unit.x * v_sphere.x + v_seg_unit.y * v_sphere.y;
            tCol = fRange * (x1 - x2) * v_seg_mag_inv;
            return tCol < 0 ? 0 : tCol;
         }
         if(v_sphere_mag_sq < radius_sq)
         {
            return 0;
         }
         return -1;
      }
   }
}

