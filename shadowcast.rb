# Shadowcasting algorithm, mainly for use by AI

MULT = [
  1, 0, 0, -1, -1, 0, 0, 1,
  0, 1, -1, 0, 0, -1, 1, 0,
  0, 1, 1, 0, 0, -1, -1, 0,
  1, 0, 0, 1, -1, 0, 0, -1
]

def compute_fov(grid, grid_w, grid_h, x, y, radius, visible_tiles)
  visible_tiles[y * grid_w + x] = 1
  radius2 = radius * radius
  octant = 0

  while octant < 8
    row = 1
    start_slope = 1.0
    end_slope = 0.0

    xx = MULT[octant]
    xy = MULT[octant + 8]
    yx = MULT[octant + 16]
    yy = MULT[octant + 24]

    while row <= radius
      dx = -row - 1
      dy = -row
      blocked = false
      new_start = 0.0

      while dx <= 0
        dx += 1
        cell_x = x + dx * xx + dy * xy
        cell_y = y + dx * yx + dy * yy
        l_slope = (dx - 0.5) / (dy + 0.5)
        r_slope = (dx + 0.5) / (dy - 0.5)

        break if end_slope > l_slope
        next if start_slope < r_slope

        cell_index = cell_y * grid_w + cell_x
        if dx * dx + dy * dy < radius2 && cell_x >= 0 && cell_y >= 0 && cell_x < grid_w && cell_y < grid_h
          visible_tiles[cell_index] = 1
        end

        if blocked
          if cell_x >= 0 && cell_y >= 0 && cell_x < grid_w && cell_y < grid_h && grid[cell_index] == 1
            new_start = r_slope
          else
            blocked = false
            start_slope = new_start
          end
        elsif cell_x >= 0 && cell_y >= 0 && cell_x < grid_w && cell_y < grid_h && grid[cell_index] == 1 && row < radius
          blocked = true
          new_start = r_slope
        end
      end

      break if blocked
      row += 1
    end
    octant += 1
  end
end


def compute_fov_cone(grid, grid_w, grid_h, x, y, radius, visible_tiles, fov_angle, direction_angle)
  visible_tiles[y.to_i * grid_w + x.to_i] = 1
  radius2 = radius * radius
  half_fov = fov_angle * 0.5

  octant = 0
  while octant < 8
    row = 1
    start_slope = 1.0
    end_slope = 0.0

    xx = MULT[octant]
    xy = MULT[octant + 8]
    yx = MULT[octant + 16]
    yy = MULT[octant + 24]

    while row <= radius
      dx = -row - 1
      dy = -row
      blocked = false
      new_start = 0.0

      while dx <= 0
        dx += 1
        cell_x = x + dx * xx + dy * xy
        cell_y = y + dx * yx + dy * yy
        l_slope = (dx - 0.5) / (dy + 0.5)
        r_slope = (dx + 0.5) / (dy - 0.5)

        break if end_slope > l_slope
        next if start_slope < r_slope

        angle = Math.atan2(cell_y - y, cell_x - x) * RAD2DEG
        angle_diff = (angle - direction_angle + 360) % 360

        if angle_diff <= half_fov || angle_diff >= 360 - half_fov
          if cell_x >= 0 && cell_y >= 0 && cell_x < grid_w && cell_y < grid_h
            cell_index = cell_y * grid_w + cell_x
            if dx * dx + dy * dy < radius2
              visible_tiles[cell_index] = 1
            end

            if blocked
              if grid[cell_index] == 1
                new_start = r_slope
              else
                blocked = false
                start_slope = new_start
              end
            elsif grid[cell_index] == 1 && row < radius
              blocked = true
              new_start = r_slope
            end
          end
        end
      end


      break if blocked
      row += 1
    end
    octant += 1
  end
end
