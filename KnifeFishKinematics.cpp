// Filename : IBEELKinematics.cpp
// Created by Amneet Bhalla on 1/1/2012.
// Updated for compataibilty by Namu Patel on 06/26/2015.

// Copyright (c) 2002-2014, Amneet Bhalla and Boyce Griffith
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//    * Redistributions of source code must retain the above copyright notice,
//      this list of conditions and the following disclaimer.
//
//    * Redistributions in binary form must reproduce the above copyright
//      notice, this list of conditions and the following disclaimer in the
//      documentation and/or other materials provided with the distribution.
//
//    * Neither the name of The University of North Carolina nor the names of
//      its contributors may be used to endorse or promote products derived from
//      this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

//////////////////////////// INCLUDES /////////////////////////////////////////

//SAMRAI INCLUDES
#include <tbox/PIO.h>
#include <tbox/SAMRAI_MPI.h>
#include <tbox/Utilities.h>

//IBAMR INCLUDES
#include <ibamr/namespaces.h>

//C++ INCLUDES
#include <string>

// Application
#include "KnifeFishKinematics.h"

namespace IBAMR
{
  
namespace
{
    static const bool DISCARD_COMMENTS = false;
    static const double PII = 3.1415926535897932384626433832795;
  
    inline std::string 
    discard_comments(const std::string& input_string)
    {
        // Create a copy of the input string, but without any text following a '!',
        // '#', or '%' character.
         std::string output_string = input_string;
         std::istringstream string_stream;

        // Discard any text following a '!' character.
         string_stream.str(output_string);
         std::getline(string_stream, output_string, '!');
         string_stream.clear();

        // Discard any text following a '#' character.
         string_stream.str(output_string);
         std::getline(string_stream, output_string, '#');
         string_stream.clear();

        // Discard any text following a '%' character.
         string_stream.str(output_string);
         std::getline(string_stream, output_string, '%');
         string_stream.clear();
         return output_string;
     }// discard_comments
  
} //namespace anonymous

KnifeFishKinematics::KnifeFishKinematics(
    const std::string& object_name,
    SAMRAI::tbox::Pointer<SAMRAI::tbox::Database> input_db,
    IBTK::LDataManager* l_data_manager,
    SAMRAI::tbox::Pointer<SAMRAI::hier::PatchHierarchy<NDIM> > patch_hierarchy,
    bool register_for_restart)
    : ConstraintIBKinematics(object_name,input_db,l_data_manager,register_for_restart),
      d_kinematics_vel(NDIM), 
      d_shape(NDIM), 
      d_current_time(0.0)
{

    // NOTE: Parent class constructor registers class with the restart manager, sets object name. 
      
        //Set the size of vectors.
    const StructureParameters& struct_param           = getStructureParameters();
    const int coarsest_ln                             = struct_param.getCoarsestLevelNumber();
    const int finest_ln                               = struct_param.getFinestLevelNumber();
    TBOX_ASSERT(coarsest_ln == finest_ln);
    const std::vector<std::pair<int,int> >& idx_range = struct_param.getLagIdxRange();

    const int nodes_body = idx_range[0].second - idx_range[0].first;
    for(int d = 0; d < NDIM; ++d)
    {
	d_kinematics_vel[d].resize(nodes_body);
	d_shape[d].resize(nodes_body);
    }
    
    SAMRAI::tbox::Array<double> forward_swim_vel; 
    if(input_db->keyExists("forward_swim_vel"))
    {
        forward_swim_vel = input_db->getDoubleArray("forward_swim_vel");
	TBOX_ASSERT( forward_swim_vel.getSize() == NDIM );
    }
    else
    {
        TBOX_ERROR(" KnifefishKinematics::KnifefishKinematics() :: Forward swimming velocity does not exist in the InputDatabase \n\n" << std::endl );
    }
    for (unsigned int d = 0; d < NDIM; ++d)
	std::fill(d_kinematics_vel[d].begin(), d_kinematics_vel[d].end(), forward_swim_vel[d]); 
    
    bool from_restart = RestartManager::getManager()->isFromRestart();
    if(from_restart) 
    {
        getFromRestart();       
    }
  
    // set current velocity using current time for initial and restarted runs.
    setKnifefishSpecificVelocity(d_current_time);    
 
    return;
  
} //KnifeFishKinematics


KnifeFishKinematics::~KnifeFishKinematics()
{
    //intentionally left blank
    return;
  
}//~KnifeFishKinematics


void 
KnifeFishKinematics::getFromRestart()
{
    Pointer<Database> restart_db = RestartManager::getManager()->getRootDatabase();
    Pointer<Database> db;
    if (restart_db->isDatabase(d_object_name))
    {
        db = restart_db->getDatabase(d_object_name);
    }
    else
    {
        TBOX_ERROR(d_object_name << ":  Restart database corresponding to "
                   << d_object_name << " not found in restart file." << std::endl);
    }
  
    d_current_time = db->getDouble("d_current_time");
     
    return;
  
}//getFromRestart


void 
KnifeFishKinematics::putToDatabase(Pointer< Database > db)
{
    IBAMR::ConstraintIBKinematics::putToDatabase(db);
    db->putDouble("d_current_time", d_current_time);
    return;
    
}// putToDatabase


void
KnifeFishKinematics::setKnifefishSpecificVelocity(
    const double time)
{
    return; 
}//setKnifefishSpecificVelocity

void
KnifeFishKinematics::setKinematicsVelocity(
     const double new_time,
     const std::vector<double>& /*incremented_angle_from_reference_axis*/,
     const std::vector<double>& /*center_of_mass*/,
     const std::vector<double>& /*tagged_pt_position*/)
{
   
    d_new_time = new_time;
    // fill current velocity at new time
    if(!MathUtilities<double>::equalEps(0.0, d_new_time))
        setKnifefishSpecificVelocity(d_new_time);
   
    d_current_time = d_new_time;
    
    return;
      
}//setKinematicsVelocity


const std::vector<std::vector<double> >&
KnifeFishKinematics::getKinematicsVelocity(
    const int /*level*/) const
{
   
    return d_kinematics_vel;

} //getKinematicsVelocity

void
KnifeFishKinematics::setShape(const double /*time*/, 
    const std::vector<double>& /*incremented_angle_from_reference_axis*/)
{
    //intentionally left blank
    return;
  
} //setShape

const std::vector<std::vector<double> >&
KnifeFishKinematics::getShape(const int /*level*/) const
{
  
    return d_shape;
  
} //getNewShape


} //namespace IBAMR
