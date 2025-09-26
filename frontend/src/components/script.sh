#!/bin/bash

# Create AuthenticatedImage.js
cat << 'EOF' > AuthenticatedImage.js
import React, { useState, useEffect } from 'react';

/**
 * A component to display an image from a protected API endpoint.
 * It fetches the image data as a blob using an authenticated API call
 * and then renders it, handling loading, error, and memory cleanup.
 * @param {object} props
 * @param {() => Promise<any>} props.fetchImage - The async function that fetches the image.
 * @param {string} props.alt - The alt text for the image.
 * @param {object} props.style - The style object for the image tag.
 */
function AuthenticatedImage({ fetchImage, alt, style }) {
  const [imageSrc, setImageSrc] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  useEffect(() => {
    let isMounted = true;
    let objectUrl = null;

    const loadImage = async () => {
      try {
        const response = await fetchImage();
        objectUrl = URL.createObjectURL(response.data);
        if (isMounted) {
          setImageSrc(objectUrl);
        }
      } catch (err) {
        console.error("Failed to load authenticated image:", err);
        if (isMounted) setError(true);
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    loadImage();

    return () => {
      isMounted = false;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [fetchImage]);

  if (loading) return <span>Loading...</span>;
  if (error || !imageSrc) return <span>Error</span>;
  
  return <img src={imageSrc} alt={alt} style={style} />;
}

export default AuthenticatedImage;
EOF

# Create InvoiceComponent.js
cat << 'EOF' > InvoiceComponent.js
import React from 'react';
import { Table, Row, Col, Container } from 'react-bootstrap';

const InvoiceComponent = React.forwardRef(({ order }, ref) => {
  if (!order) return null;

  const subtotal = order.items.reduce((acc, item) => acc + (item.quantity * item.unit_price), 0);
  const taxRate = 0.08;
  const tax = subtotal * taxRate;
  const total = subtotal + tax;

  return (
    <div ref={ref} className="p-5">
      <Container>
        <Row className="mb-4 align-items-center">
          <Col>
            <h1 className="mb-0">INVOICE</h1>
            <p className="text-muted">Your Company Name</p>
          </Col>
          <Col className="text-end">
            <p className="mb-0"><strong>Order #:</strong> SO-{order.id}</p>
            <p className="mb-0"><strong>Date:</strong> {new Date(order.order_date).toLocaleDateString()}</p>
          </Col>
        </Row>

        <hr />

        <Row className="mb-4">
          <Col>
            <strong>Bill To:</strong>
            <p className="mb-0">{order.customer_name || 'Valued Customer'}</p>
          </Col>
        </Row>

        <Table striped bordered hover responsive>
          <thead>
            <tr>
              <th>Product</th>
              <th>SKU</th>
              <th>Quantity</th>
              <th>Unit Price</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            {order.items.map((item) => (
              <tr key={item.id}>
                <td>{item.product.name}</td>
                <td>{item.product.sku}</td>
                <td>{item.quantity}</td>
                <td>₹{parseFloat(item.unit_price).toFixed(2)}</td>
                <td>₹{(item.quantity * item.unit_price).toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </Table>

        <Row className="mt-4 justify-content-end">
          <Col md={4}>
            <Table borderless size="sm">
              <tbody>
                <tr>
                  <td><strong>Subtotal:</strong></td>
                  <td className="text-end">₹{subtotal.toFixed(2)}</td>
                </tr>
                <tr>
                  <td><strong>Tax ({(taxRate * 100).toFixed(0)}%):</strong></td>
                  <td className="text-end">₹{tax.toFixed(2)}</td>
                </tr>
                <tr className="border-top">
                  <td className="pt-2"><strong>Total:</strong></td>
                  <td className="text-end pt-2"><strong>₹{total.toFixed(2)}</strong></td>
                </tr>
              </tbody>
            </Table>
          </Col>
        </Row>
      </Container>
    </div>
  );
});

export default InvoiceComponent;
EOF

# Create ProductFormModal.js
cat << 'EOF' > ProductFormModal.js
import React, { useState, useEffect } from 'react';
import { Modal, Button, Form, Spinner } from 'react-bootstrap';
import { getSuppliers } from '../services/api';

function ProductFormModal({ show, handleClose, product, onSave }) {
  const [formData, setFormData] = useState({});
  const [suppliers, setSuppliers] = useState([]);
  const [loadingSuppliers, setLoadingSuppliers] = useState(false);

  useEffect(() => {
    if (product) setFormData({ ...product, preferred_supplier: product.preferred_supplier || '' });
    else setFormData({ name: '', sku: '', category: '', unit_price: '', stock_quantity: '', min_stock_level: '', preferred_supplier: '' });

    if (show) {
      const fetchSuppliers = async () => {
        setLoadingSuppliers(true);
        try { const response = await getSuppliers(); setSuppliers(response.data); } 
        catch (error) { console.error("Failed to fetch suppliers", error); } 
        finally { setLoadingSuppliers(false); }
      };
      fetchSuppliers();
    }
  }, [product, show]);

  const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });
  const handleSubmit = (e) => { e.preventDefault(); onSave(formData); };

  return (
    <Modal show={show} onHide={handleClose}>
      <Modal.Header closeButton><Modal.Title>{product ? 'Edit Product' : 'Create Product'}</Modal.Title></Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <Form.Group className="mb-3"><Form.Label>Name</Form.Label><Form.Control type="text" name="name" value={formData.name || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>SKU</Form.Label><Form.Control type="text" name="sku" value={formData.sku || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Category</Form.Label><Form.Control type="text" name="category" value={formData.category || ''} onChange={handleChange} /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Unit Price</Form.Label><Form.Control type="number" name="unit_price" value={formData.unit_price || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Stock Quantity</Form.Label><Form.Control type="number" name="stock_quantity" value={formData.stock_quantity || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Minimum Stock Level</Form.Label><Form.Control type="number" name="min_stock_level" value={formData.min_stock_level || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3">
            <Form.Label>Preferred Supplier</Form.Label>
            {loadingSuppliers ? <Spinner size="sm" /> : (
              <Form.Select name="preferred_supplier" value={formData.preferred_supplier || ''} onChange={handleChange}>
                <option value="">None</option>
                {suppliers.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
              </Form.Select>
            )}
          </Form.Group>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>Close</Button>
          <Button variant="primary" type="submit">Save Changes</Button>
        </Modal.Footer>
      </Form>
    </Modal>
  );
}

export default ProductFormModal;
EOF

# Create ProtectedRoute.js
cat << 'EOF' > ProtectedRoute.js
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

function ProtectedRoute({ children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  return children;
}

export default ProtectedRoute;
EOF

# Create PublicRoute.js
cat << 'EOF' > PublicRoute.js
import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

function PublicRoute({ children }) {
  const { user } = useAuth();
  if (user) return <Navigate to="/" />;
  return children;
}

export default PublicRoute;
EOF

# Create RoleRequired.js
cat << 'EOF' > RoleRequired.js
import { useAuth } from '../context/AuthContext';

function RoleRequired({ allowedRoles, children }) {
  const { user } = useAuth();
  if (user && allowedRoles.includes(user.role)) return <>{children}</>;
  return null;
}

export default RoleRequired;
EOF

# Create SupplierFormModal.js
cat << 'EOF' > SupplierFormModal.js
import React, { useState, useEffect } from 'react';
import { Modal, Button, Form } from 'react-bootstrap';

function SupplierFormModal({ show, handleClose, supplier, onSave }) {
  const [formData, setFormData] = useState({});

  useEffect(() => {
    if (supplier) setFormData(supplier);
    else setFormData({ name: '', email: '', phone: '', contact_info: '' });
  }, [supplier, show]);

  const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });
  const handleSubmit = (e) => { e.preventDefault(); onSave(formData); };

  return (
    <Modal show={show} onHide={handleClose}>
      <Modal.Header closeButton>
        <Modal.Title>{supplier ? 'Edit Supplier' : 'Create Supplier'}</Modal.Title>
      </Modal.Header>
      <Form onSubmit={handleSubmit}>
        <Modal.Body>
          <Form.Group className="mb-3"><Form.Label>Name</Form.Label><Form.Control type="text" name="name" value={formData.name || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Email</Form.Label><Form.Control type="email" name="email" value={formData.email || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Phone</Form.Label><Form.Control type="text" name="phone" value={formData.phone || ''} onChange={handleChange} required /></Form.Group>
          <Form.Group className="mb-3"><Form.Label>Contact Info</Form.Label><Form.Control as="textarea" rows={3} name="contact_info" value={formData.contact_info || ''} onChange={handleChange} /></Form.Group>
        </Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={handleClose}>Close</Button>
          <Button variant="primary" type="submit">Save Changes</Button>
        </Modal.Footer>
      </Form>
    </Modal>
  );
}

export default SupplierFormModal;
EOF

echo "All JS files created successfully."
