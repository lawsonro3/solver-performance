Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs 
    tolerance: 1e-5
    max_iterations: 300
    kspace: 75
    output_level: 0

  - name: solve_cont
    type: tpetra
    method: gmres
    preconditioner: muelu
    tolerance: 1e-5
    max_iterations: 300
    kspace: 50
    output_level: 0
    muelu_xml_file_name: muelu-l1gs4-drop0.02-unsmoo-noqr.xml

realms:

  - name: realm_1
    mesh: ../../../meshes/V27/V27_41a_R1.exo 
    use_edges: no       
    activate_aura: no
    check_for_missing_bcs: yes 
    automatic_decomposition_type: rcb

    time_step_control:
     target_courant: 5.0
     time_step_change_factor: 1.15
     #time_step_change_factor: 1.0
   
    equation_systems:
      name: theEqSys
      max_iterations: 2 
   
      solver_system_specification:
        pressure: solve_cont
        velocity: solve_scalar
        dpdx: solve_scalar
 
      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206, block_106.Tetrahedron_4._urpconv, block_206.Tetrahedron_4._urpconv]
        value:
          pressure: 0
          velocity: [7.6,0.0,0.0]

    material_properties:
      target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206, block_106.Tetrahedron_4._urpconv, block_206.Tetrahedron_4._urpconv]
      specifications:
        - name: density
          type: constant
          value: 1.2

        - name: viscosity
          type: constant
          value: 1.8e-5

    boundary_conditions:

    - inflow_boundary_condition: bc_front
      target_name: surface_1
      inflow_user_data:
        velocity: [7.6,0.0,0.0]

    - open_boundary_condition: bc_back
      target_name: surface_2
      open_user_data:
        pressure: 0.0

    - symmetry_boundary_condition: bc_top
      target_name: surface_3
      symmetry_user_data:

    - symmetry_boundary_condition: bc_sides
      target_name: surface_4
      symmetry_user_data:

    - wall_boundary_condition: bc_ground
      target_name: surface_6
      wall_user_data:
        velocity: [0.0,0.0,0.0]
        use_wall_function: no 

    - wall_boundary_condition: bc_tower
      target_name: surface_7
      wall_user_data:
        velocity: [0.0,0.0,0.0]
        use_wall_function: no 

    - wall_boundary_condition: bc_nacelle
      target_name: surface_8
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no

    - wall_boundary_condition: bc_back_strip
      target_name: surface_9
      wall_user_data:
        velocity: [0.0,0.0,0.0]
        use_wall_function: no 

    - wall_boundary_condition: bc_cone
      target_name: surface_10
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]
        use_wall_function: no 

    - wall_boundary_condition: bc_blade1
      target_name: surface_11
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]
        use_wall_function: no 

    - wall_boundary_condition: bc_blade2
      target_name: surface_12
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]
        use_wall_function: no 

    - wall_boundary_condition: bc_blade3
      target_name: surface_13
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]
        use_wall_function: no 

    - non_conformal_boundary_condition: bc_in_out
      current_target_name: [surface_19, surface_15, surface_17]
      opposing_target_name: [surface_18, surface_14, surface_16]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.005
        search_method: stk_kdtree

    - non_conformal_boundary_condition: bc_out_in
      current_target_name: [surface_18, surface_14, surface_16]
      opposing_target_name: [surface_19, surface_15, surface_17]
      non_conformal_user_data:
        expand_box_percentage: 5.0
        search_tolerance: 0.005
        search_method: stk_kdtree

    solution_options:
      name: myOptions
      turbulence_model: wale 
      use_consolidated_solver_algorithm: yes 

      mesh_motion:

        - name: mmOne
          target_name: [block_101, block_104, block_105, block_106]
          omega: 4.237 
          unit_vector: [0.9975640502598242, 0.0, -0.0697564737441253] 
          compute_centroid: yes

        - name: mmTwo
          target_name: [block_201, block_204, block_205, block_206]
          omega: 0.0

      options:

        - element_source_terms:
            momentum: [lumped_momentum_time_derivative, advection_diffusion, NSO_2ND_ALT]
            continuity: advection

        - consistent_mass_matrix_png:
            pressure: no 
            velocity: no

        - non_conformal:
            gauss_labatto_quadrature: no
            algorithm_type: dg
            upwind_advection: no
            current_normal: yes 
            include_png_penalty: no
            activate_coincident_node_error_check: no 
          
        - shifted_gradient_operator:
            velocity: no
            pressure: yes 
  
    post_processing:
    
    - type: surface
      physics: surface_force_and_moment
      output_file_name: fullV27_41.dat-s002
      frequency: 25 
      parameters: [-0.206163, 4.66517e-08, 0.0135008] 
      target_name: [surface_11, surface_12, surface_13]

    output:
      output_data_base_name: out_muelu/fullV27_41a_R1.e
      output_start: 10000
      output_frequency: 10000
      output_node_set: no 
      output_variables:
       - velocity
       - pressure
       - mesh_displacement
       - turbulent_viscosity

    restart:
      restart_data_base_name: rst_muelu/fullV27_41a_R1.rst
      restart_frequency: 20
      restart_start: 20
      #restart_forced_wall_time: 47.8
#      restart_time: 10000.0
 
Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: 20
      time_step: 5.0e-6 
      #time_stepping_type: fixed
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: no 

      realms:
        - realm_1
