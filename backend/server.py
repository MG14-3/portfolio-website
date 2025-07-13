from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
from pymongo import MongoClient
from typing import Optional
import os
from datetime import datetime
import uuid

# Initialize FastAPI app
app = FastAPI(title="Portfolio Backend", version="1.0.0")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB connection
MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017/portfolio")
client = MongoClient(MONGO_URL)
db = client.portfolio

# Pydantic models
class ContactMessage(BaseModel):
    name: str
    email: EmailStr
    message: str

class ContactResponse(BaseModel):
    id: str
    name: str
    email: str
    message: str
    created_at: datetime
    status: str = "new"

# Health check endpoint
@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "service": "portfolio-backend"}

# Contact form endpoint
@app.post("/api/contact", response_model=dict)
async def submit_contact_form(contact_data: ContactMessage):
    try:
        # Create contact document
        contact_doc = {
            "id": str(uuid.uuid4()),
            "name": contact_data.name,
            "email": contact_data.email,
            "message": contact_data.message,
            "created_at": datetime.utcnow(),
            "status": "new"
        }
        
        # Insert into MongoDB
        result = db.contacts.insert_one(contact_doc)
        
        if result.inserted_id:
            return {
                "success": True,
                "message": "Contact form submitted successfully",
                "contact_id": contact_doc["id"]
            }
        else:
            raise HTTPException(status_code=500, detail="Failed to save contact message")
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing contact form: {str(e)}")

# Get all contact messages (admin endpoint)
@app.get("/api/admin/contacts")
async def get_all_contacts():
    try:
        contacts = list(db.contacts.find({}, {"_id": 0}).sort("created_at", -1))
        return {
            "success": True,
            "contacts": contacts,
            "total": len(contacts)
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching contacts: {str(e)}")

# Get contact by ID
@app.get("/api/admin/contacts/{contact_id}")
async def get_contact_by_id(contact_id: str):
    try:
        contact = db.contacts.find_one({"id": contact_id}, {"_id": 0})
        if not contact:
            raise HTTPException(status_code=404, detail="Contact not found")
        return {
            "success": True,
            "contact": contact
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching contact: {str(e)}")

# Update contact status
@app.patch("/api/admin/contacts/{contact_id}")
async def update_contact_status(contact_id: str, status: str):
    try:
        valid_statuses = ["new", "read", "responded", "archived"]
        if status not in valid_statuses:
            raise HTTPException(status_code=400, detail=f"Invalid status. Must be one of: {valid_statuses}")
        
        result = db.contacts.update_one(
            {"id": contact_id},
            {"$set": {"status": status, "updated_at": datetime.utcnow()}}
        )
        
        if result.matched_count == 0:
            raise HTTPException(status_code=404, detail="Contact not found")
        
        return {
            "success": True,
            "message": f"Contact status updated to {status}"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error updating contact: {str(e)}")

# Delete contact
@app.delete("/api/admin/contacts/{contact_id}")
async def delete_contact(contact_id: str):
    try:
        result = db.contacts.delete_one({"id": contact_id})
        
        if result.deleted_count == 0:
            raise HTTPException(status_code=404, detail="Contact not found")
        
        return {
            "success": True,
            "message": "Contact deleted successfully"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error deleting contact: {str(e)}")

# Portfolio data endpoints (for dynamic content)
@app.get("/api/portfolio/projects")
async def get_projects():
    try:
        projects = list(db.projects.find({}, {"_id": 0}).sort("order", 1))
        return {
            "success": True,
            "projects": projects
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching projects: {str(e)}")

@app.get("/api/portfolio/skills")
async def get_skills():
    try:
        skills = list(db.skills.find({}, {"_id": 0}).sort("category", 1))
        return {
            "success": True,
            "skills": skills
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching skills: {str(e)}")

@app.get("/api/portfolio/about")
async def get_about_info():
    try:
        about = db.about.find_one({}, {"_id": 0})
        if not about:
            # Return default about info if not found
            about = {
                "name": "Mangalam Shrivastava",
                "title": "Web Developer & Data Enthusiast",
                "bio": "BTech CSE student at VIT (2027) passionate about building impactful tech — from smart mirrors to scrapers.",
                "location": "India",
                "email": "shrivastavam017@gmail.com",
                "phone": "+91 9006113140",
                "social": {
                    "github": "https://github.com/MG14-3",
                    "linkedin": "https://linkedin.com/in/mangalamshrivastava",
                    "twitter": ""
                }
            }
        return {
            "success": True,
            "about": about
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching about info: {str(e)}")

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Portfolio Backend API", "version": "1.0.0"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)