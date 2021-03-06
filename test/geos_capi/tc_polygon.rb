# -----------------------------------------------------------------------------
#
# Tests for the GEOS polygon implementation
#
# -----------------------------------------------------------------------------

require 'test/unit'
require 'rgeo'

require ::File.expand_path('../common/polygon_tests.rb', ::File.dirname(__FILE__))


module RGeo
  module Tests  # :nodoc:
    module GeosCAPI  # :nodoc:

      class TestPolygon < ::Test::Unit::TestCase  # :nodoc:


        def setup
          @factory = ::RGeo::Geos.factory
        end


        include ::RGeo::Tests::Common::PolygonTests


        def test_intersection
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 2)
          point3_ = @factory.point(2, 2)
          point4_ = @factory.point(2, 0)
          poly1_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point3_, point4_]))
          poly2_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point4_]))
          poly3_ = poly1_.intersection(poly2_)
          assert_equal(poly2_, poly3_)
        end


        def test_union
          point1_ = @factory.point(0, 0)
          point2_ = @factory.point(0, 2)
          point3_ = @factory.point(2, 2)
          point4_ = @factory.point(2, 0)
          poly1_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point3_, point4_]))
          poly2_ = @factory.polygon(@factory.linear_ring([point1_, point2_, point4_]))
          poly3_ = poly1_.union(poly2_)
          assert_equal(poly1_, poly3_)
        end


        def test_simplify
          xys = [[0, 0], [5, 0], [10, 0], [10, 10], [5, 10.2], [0, 10], [0, 0]]
          points = xys.collect { |x,y| @factory.point(x, y) }
          poly = @factory.polygon(@factory.linear_ring(points))
          simplified = poly.simplify(0.3)
          new_points = simplified.exterior_ring.points
          extra = new_points.reject { |p| [0, 10].include?(p.x) and [0, 10].include?(p.y) }
          assert_equal 5, new_points.length, "Closed ring of the square should have 5 points"
          assert_equal 0, extra.length , "Should only have x/y's on 0 and 10"
        end

        def test_buffer
          polygon_coordinates = [[0.5527864045000421, 3.776393202250021],
                                 [0.7763932022500211, 4.447213595499958],
                                 [1.4472135954999579, 4.223606797749979],
                                 [2.447213595499958, 2.223606797749979],
                                 [2.223606797749979, 1.5527864045000421],
                                 [1.5527864045000421, 1.776393202250021],
                                 [0.5527864045000421, 3.776393202250021]]

          points_arr = polygon_coordinates.map{|v| @factory.point(v[0],v[1])}
          outer_ring = @factory.linear_ring(points_arr)
          polygon = @factory.polygon(outer_ring)

          point1 = @factory.point(2,2)
          point2 = @factory.point(1,4)
          line_string = @factory.line_string([point1,point2])
          polygon2 = line_string.buffer(0.5)

          assert_equal polygon, polygon2
        end

        def test_buffer_with_style
          polygon_coordinates = [[0.7316718427000253, 3.865835921350013],
                                 [1.0, 4.3],[6.0, 4.3],[6.3, 4.3],
                                 [6.3, 3.7],[1.4854101966249682, 3.7],
                                 [2.2683281572999747, 2.134164078649987],
                                 [2.4024922359499623, 1.8658359213500124],
                                 [1.8658359213500126, 1.597507764050038],
                                 [0.7316718427000253, 3.865835921350013]]

          points_arr = polygon_coordinates.map{|v| @factory.point(v[0],v[1])}
          outer_ring = @factory.linear_ring(points_arr)
          polygon = @factory.polygon(outer_ring)

          point1 = @factory.point(2,2)
          point2 = @factory.point(1,4)
          point3 = @factory.point(6,4)
          line_string = @factory.line_string([point1,point2,point3])
          buffered_line_string = line_string.buffer_with_style(0.3,
                                                                 RGeo::Geos::CAP_FLAT,
                                                                 RGeo::Geos::JOIN_ROUND,
                                                                 0.0)

          assert_equal polygon, buffered_line_string
        end
      end

    end
  end
end if ::RGeo::Geos.capi_supported?
